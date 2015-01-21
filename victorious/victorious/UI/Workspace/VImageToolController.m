//
//  VImageToolController.m
//  victorious
//
//  Created by Michael Sena on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageToolController.h"

#import "CIImage+VImage.h"
#import "VConstants.h"

//TODO: Should factor these out of here
#import "VCropTool.h"
#import "VFilterTool.h"
#import "VTextTool.h"

static const CGFloat kJPEGCompressionQuality    = 0.8f;

NSString * const VImageToolControllerInitialImageEditStateKey = @"VImageToolControllerInitialImageEditStateKey";

@interface VImageToolController ()

@property (nonatomic, assign) BOOL hasSetupDefaultTool;

@end

@implementation VImageToolController

- (void)exportWithSourceAsset:(NSURL *)source
               withCompletion:(void (^)(BOOL finished, NSURL *renderedMediaURL, UIImage *previewImage, NSError *error))completion
{
    NSParameterAssert(completion != nil);
    
    NSURL *tempDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *tempFile = [[tempDirectory URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:VConstantMediaExtensionJPG];
    
    __weak typeof(self) welf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
                   {
                       NSData *imageData = [NSData dataWithContentsOfURL:source];
                       UIImage *sourceImage = [UIImage imageWithData:imageData];
                       
                       UIImage *renderedImage = [welf renderedImageForCurrentStateWithSourceImage:sourceImage];
                       
                       NSData *renderedImageData = UIImageJPEGRepresentation(renderedImage, kJPEGCompressionQuality);
                       BOOL successfullyWroteToURL = [renderedImageData writeToURL:tempFile atomically:NO];
                       
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          completion(successfullyWroteToURL, tempFile, renderedImage, nil);
                                      });
                   });

}

- (UIImage *)renderedImageForCurrentStateWithSourceImage:(UIImage *)sourceImage
{
    CIContext *renderingContext = [CIContext contextWithOptions:@{}];
    
    __block CIImage *filteredImage = [CIImage v_imageWithUImage:sourceImage];
    
    NSArray *filterOrderTools = [self.tools sortedArrayUsingComparator:^NSComparisonResult(id <VWorkspaceTool> tool1, id <VWorkspaceTool> tool2)
                                 {
                                     if (tool1.renderIndex < tool2.renderIndex)
                                     {
                                         return NSOrderedAscending;
                                     }
                                     if (tool1.renderIndex > tool2.renderIndex)
                                     {
                                         return NSOrderedDescending;
                                     }
                                     return NSOrderedSame;
                                 }];
    
    [filterOrderTools enumerateObjectsUsingBlock:^(id <VWorkspaceTool> tool, NSUInteger idx, BOOL *stop)
     {
         filteredImage = [tool imageByApplyingToolToInputImage:filteredImage];
     }];
    
    CGImageRef renderedImage = [renderingContext createCGImage:filteredImage
                                                      fromRect:[filteredImage extent]];
    UIImage *image = [UIImage imageWithCGImage:renderedImage];
    CGImageRelease(renderedImage);
    return image;
}

#pragma mark - Property Accessors

- (NSString *)filterName
{
    __block NSString *filterName;
    [self.tools enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        if ([obj isKindOfClass:[VFilterTool class]])
        {
            if ([obj respondsToSelector:@selector(filterTitle)])
            {
                filterName = [obj filterTitle];
            }
        }
    }];
    return filterName;
}

- (NSString *)embeddedText
{
    __block NSString *embeddedText;
    [self.tools enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj isKindOfClass:[VTextTool class]])
         {
             if ([obj respondsToSelector:@selector(embeddedText)])
             {
                 embeddedText = [obj embeddedText];
                 *stop = YES;
             }
         }
     }];
    return embeddedText;
}

- (NSString *)textToolType
{
    __block NSString *textToolType;
    [self.tools enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj isKindOfClass:[VTextTool class]])
         {
             if ([obj respondsToSelector:@selector(textStyleTitle)])
             {
                 textToolType = [obj textStyleTitle];
                 *stop = YES;
             }
         }
     }];
    return textToolType;
}

- (BOOL)didCrop
{
    __block BOOL didCrop = NO;
    [self.tools enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        if ([obj respondsToSelector:@selector(didCrop)])
        {
            didCrop = [obj didCrop];
            *stop = YES;
        }
    }];
    return didCrop;
}

#pragma mark - Iherited Methods

- (void)setupDefaultTool
{
    if (self.hasSetupDefaultTool)
    {
        return;
    }
    self.hasSetupDefaultTool = YES;
    
    if (self.tools == nil)
    {
        NSAssert(self.tools != nil, @"Tools not set yet!");
    }
    
    [self.tools enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         switch (self.defaultImageTool)
         {
             case VImageToolControllerInitialImageEditStateFilter:
                 if ([obj isKindOfClass:[VFilterTool class]])
                 {
                     [self setSelectedTool:obj];
                     *stop = YES;
                 }
                 break;
             case VImageToolControllerInitialImageEditStateText:
                 if ([obj isKindOfClass:[VTextTool class]])
                 {
                     [self setSelectedTool:obj];
                     *stop = YES;
                 }
                 break;
             case VImageToolControllerInitialImageEditStateCrop:
             default:
                 if ([obj isKindOfClass:[VCropTool class]])
                 {
                     [self setSelectedTool:obj];
                     
                     *stop = YES;
                 }
                 break;
         }
    }];
}

@end
