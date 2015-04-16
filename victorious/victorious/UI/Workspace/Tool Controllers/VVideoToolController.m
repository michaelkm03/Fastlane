//
//  VVideoToolController.m
//  victorious
//
//  Created by Michael Sena on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoToolController.h"

#import "VVideoWorkspaceTool.h"

#import "VConstants.h"

// Should move this out of here.
#import "VTrimVideoTool.h"
#import "VVideoSnapshotTool.h"

NSString * const VVideoToolControllerInitalVideoEditStateKey = @"VVideoToolControllerInitalVideoEditStateKey";

@interface VVideoToolController ()

@property (nonatomic, assign) BOOL hasSetupDefaultTool;

@end

@implementation VVideoToolController

- (void)setSelectedTool:(id<VVideoWorkspaceTool>)selectedTool
{
    [super setSelectedTool:selectedTool];
    
    [selectedTool setMediaURL:self.mediaURL];
    
    BOOL selectedToolIsSnapshot = [selectedTool isKindOfClass:[VVideoSnapshotTool class]];
    if (self.canRenderAndExportChangeBlock)
    {
        self.canRenderAndExportChangeBlock(!selectedToolIsSnapshot);
    }
    if (selectedToolIsSnapshot)
    {
        VVideoSnapshotTool *snapshotTool = (VVideoSnapshotTool *)selectedTool;
        __weak typeof(self) welf = self;
        snapshotTool.capturedSnapshotBlock = ^void(UIImage *previewImage, NSURL *capturedMediaURL)
        {
            [welf.videoToolControllerDelegate videoToolController:self
                                       selectedSnapshotForEditing:previewImage
                                              renderedSnapshotURL:capturedMediaURL];
        };
    }
}

- (void)exportWithSourceAsset:(NSURL *)source
               withCompletion:(void (^)(BOOL finished, NSURL *renderedMediaURL, UIImage *previewImage, NSError *error))completion
{
    NSParameterAssert(completion != nil);
    
    NSURL *tempDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *tempFile = [[tempDirectory URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:VConstantMediaExtensionMP4];

    [(id <VVideoWorkspaceTool>)self.selectedTool exportToURL:tempFile
                                              withCompletion:^(BOOL finished, UIImage *previewImage, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^
         {
             completion(finished, tempFile, previewImage, error);
         });
     }];
}

- (BOOL)isGIF
{
    if ([self.selectedTool isKindOfClass:[VTrimVideoTool class]])
    {
        return ((VTrimVideoTool *)self.selectedTool).isGIF;
    }
    return NO;
}

- (BOOL)didTrim
{
    return ((VTrimVideoTool *)self.selectedTool).didTrim;
}

- (void)setupDefaultTool
{
    if (self.hasSetupDefaultTool)
    {
        return;
    }
    self.hasSetupDefaultTool = YES;
    
    if ( self.tools == nil || self.tools.count == 0 )
    {
        NSAssert(false, @"Tools not set yet!");
    }
    
    [self.tools enumerateObjectsUsingBlock:^(id <VWorkspaceTool> obj, NSUInteger idx, BOOL *stop)
     {
         switch (self.defaultVideoTool)
         {
             case VVideoToolControllerInitialVideoEditStateVideo:
                 if ([obj isKindOfClass:[VTrimVideoTool class]])
                 {
                     VTrimVideoTool *trimTool = (VTrimVideoTool *)obj;
                     if (!trimTool.isGIF)
                     {
                         [self setSelectedTool:obj];
                         *stop = YES;
                     }
                 }
                 break;
             case VVideoToolControllerInitialVideoEditStateGIF:
                 if ([obj isKindOfClass:[VTrimVideoTool class]])
                 {
                     VTrimVideoTool *trimTool = (VTrimVideoTool *)obj;
                     if (trimTool.isGIF)
                     {
                         [self setSelectedTool:obj];
                         *stop = YES;
                     }
                 }
                 break;
             case VVideoToolControllerInitialVideoEditStateMeme:
                 if ([obj isKindOfClass:[VVideoSnapshotTool class]])
                 {
                     [self setSelectedTool:obj];
                     *stop = YES;
                 }
                 break;
         }
     }];
}

@end
