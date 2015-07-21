//
//  VToolController.m
//  victorious
//
//  Created by Michael Sena on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VToolController.h"

#import "NSArray+VMap.h"

// Image Blurring
#import "NSURL+MediaType.h"
#import "UIImage+ImageEffects.h"

#import "VCanvasView.h"

@import AVFoundation;

@interface VToolController ()

@property (nonatomic, strong, readwrite) NSArray *tools;

@property (nonatomic, strong) UIViewController *canvasToolViewController;
@property (nonatomic, strong) UIViewController *inspectorToolViewController;

@end

@implementation VToolController

- (instancetype)initWithTools:(NSArray *)tools
{
    self = [super init];
    if (self)
    {
        _tools = tools;
    }
    return self;
}

#pragma mark - Property Accessors

- (void)setSelectedTool:(id<VWorkspaceTool>)selectedTool
{
    // Re-selected current tool should we dismiss?
    if (selectedTool == _selectedTool)
    {
        return;
    }
    
    if ([selectedTool respondsToSelector:@selector(setCanvasView:)] && self.canvasView)
    {
        [selectedTool setCanvasView:self.canvasView];
    }
    
    if (([_selectedTool respondsToSelector:@selector(shouldLeaveToolOnCanvas)]))
    {
        if ([_selectedTool shouldLeaveToolOnCanvas])
        {
            self.canvasToolViewController = nil;
        }
    }
    
    if (self.canvasToolViewController)
    {
        [self.delegate removeCanvasViewController:self.canvasToolViewController];
    }
    
    if ([selectedTool respondsToSelector:@selector(canvasToolViewController)])
    {
        // In case this viewController's view was disabled but left on the canvas
        [self.delegate addCanvasViewController:[selectedTool canvasToolViewController]];
        self.canvasToolViewController = [selectedTool canvasToolViewController];
    }
    
    if ([selectedTool respondsToSelector:@selector(inspectorToolViewController)])
    {
        [self.delegate setInspectorViewController:[selectedTool inspectorToolViewController]];
    }
    else
    {
        [self.delegate setInspectorViewController:nil];
    }
    if ([_selectedTool respondsToSelector:@selector(setSelected:)])
    {
        [_selectedTool setSelected:NO];
    }
    
    if ([selectedTool respondsToSelector:@selector(setSelected:)])
    {
        [selectedTool setSelected:YES];
    }
    
    if ([selectedTool respondsToSelector:@selector(canvasScrollViewShoudldBeInteractive)])
    {
        self.canvasView.canvasScrollView.userInteractionEnabled = [selectedTool canvasScrollViewShoudldBeInteractive];
    }
    else
    {
        self.canvasView.canvasScrollView.userInteractionEnabled = NO;
    }
    
    _selectedTool = selectedTool;
}

- (void)setMediaURL:(NSURL *)mediaURL
{
    _mediaURL = mediaURL;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       UIImage *image;
                       if ([mediaURL v_hasImageExtension])
                       {
                           image = [UIImage imageWithData:[NSData dataWithContentsOfURL:mediaURL]];
                       }
                       else if ([mediaURL v_hasVideoExtension])
                       {
                           AVAsset *assetWithURL = [AVAsset assetWithURL:mediaURL];
                           AVAssetImageGenerator *imageGenrator = [AVAssetImageGenerator assetImageGeneratorWithAsset:assetWithURL];
                           CGImageRef imageRef = [imageGenrator copyCGImageAtTime:kCMTimeZero
                                                                       actualTime:NULL
                                                                            error:nil];
                           image = [UIImage imageWithCGImage:imageRef];
                           CGImageRelease(imageRef);
                       }
                       if (image == nil)
                       {
                           return;
                       }
                       dispatch_async(dispatch_get_main_queue(), ^
                       {
                           if (self.snapshotImageBecameAvailable != nil)
                           {
                               self.snapshotImageBecameAvailable(image);
                           }
                       });
                   });
}

#pragma mark - Public Methods

- (void)setupDefaultTool
{
    NSAssert(false, @"Implement me in subclasses!");
}

- (void)exportWithSourceAsset:(NSURL *)source
               withCompletion:(void (^)(BOOL finished, NSURL *renderedMediaURL, UIImage *previewImage, NSError *error))completion
{
    NSAssert(false, @"Subclasses must implement me!");
}

- (void)disableTool:(id)tool
{
    NSMutableArray *newTools = [[NSMutableArray alloc] init];
    for (id existingTool in self.tools)
    {
        if (existingTool != tool)
        {
            [newTools addObject:existingTool];
        }
    }
    _tools = newTools;
}

@end
