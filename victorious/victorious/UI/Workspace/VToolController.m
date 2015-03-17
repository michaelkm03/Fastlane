//
//  VToolController.m
//  victorious
//
//  Created by Michael Sena on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VToolController.h"

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
            self.canvasToolViewController.view.userInteractionEnabled = NO;
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
        [selectedTool canvasToolViewController].view.userInteractionEnabled = YES;
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
    
    _selectedTool = selectedTool;
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

@end
