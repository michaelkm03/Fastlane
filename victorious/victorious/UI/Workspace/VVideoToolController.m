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

@implementation VVideoToolController

- (void)setSelectedTool:(id<VVideoWorkspaceTool>)selectedTool
{
    [super setSelectedTool:selectedTool];
    
    if ([selectedTool conformsToProtocol:@protocol(VVideoWorkspaceTool)])
    {
        id <VVideoWorkspaceTool> videoTool = (id <VVideoWorkspaceTool>)selectedTool;
        if ([videoTool respondsToSelector:@selector(setMediaURL:)])
        {
            [videoTool setMediaURL:self.mediaURL];
        }

        if ([videoTool respondsToSelector:@selector(setPlayerView:)])
        {
            [videoTool setPlayerView:self.playerView];
        }
    }
}

- (void)exportWithSourceAsset:(NSURL *)source
               withCompletion:(void (^)(BOOL finished, NSURL *renderedMediaURL, UIImage *previewImage))completion
{
    NSURL *tempDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *tempFile = [[tempDirectory URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:VConstantMediaExtensionMP4];

    [(id <VVideoWorkspaceTool>)self.selectedTool exportToURL:tempFile
                                              withCompletion:^(BOOL finished, UIImage *previewImage)
     {
         dispatch_async(dispatch_get_main_queue(), ^
         {
             completion(finished, tempFile, previewImage);
         });
     }];
}

@end
