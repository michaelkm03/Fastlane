//
//  VImageToolController.m
//  victorious
//
//  Created by Michael Sena on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageToolController.h"

#import "CIImage+VImage.h"

static const CGFloat kJPEGCompressionQuality    = 0.8f;

@implementation VImageToolController

- (void)exportToURL:(NSURL *)url
        sourceAsset:(NSURL *)source
     withCompletion:(void (^)(BOOL, UIImage *))completion
{
    __weak typeof(self) welf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
                   {
                       NSData *imageData = [NSData dataWithContentsOfURL:source];
                       UIImage *sourceImage = [UIImage imageWithData:imageData];
                       
                       UIImage *renderedImage = [welf renderedImageForCurrentStateWithSourceImage:sourceImage];
                       
                       NSData *renderedImageData = UIImageJPEGRepresentation(renderedImage, kJPEGCompressionQuality);
                       BOOL successfullyWroteToURL = [renderedImageData writeToURL:url atomically:NO];
                       
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          completion(successfullyWroteToURL, renderedImage);
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

@end
