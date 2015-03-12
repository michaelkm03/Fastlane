//
//  VTextToolController.m
//  victorious
//
//  Created by Patrick Lynch on 3/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextToolController.h"
#import "VEditTextToolViewController.h"
#import "UIView+AutoLayout.h"
#import "VCanvasView.h"

@interface VTextToolController()

@end

@implementation VTextToolController

#pragma mark - VToolController overrides

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (void)setSelectedTool:(id<VWorkspaceTool>)selectedTool
{
    [super setSelectedTool:selectedTool];
    
    [self setHashtagText:@"TipOfTheDay"];
    
    [self updateSelectedTool];
}

- (void)setupDefaultTool
{
    if ( self.tools == nil || self.tools.count == 0 )
    {
        NSAssert( NO, @"Cannot set up default tool because there are no tools." );
    }
    
    [self setSelectedTool:self.tools.firstObject];
}

- (void)updateSelectedTool
{
    VEditTextToolViewController *canvasViewController = (VEditTextToolViewController *)self.selectedTool.canvasToolViewController;
    canvasViewController.text = self.text;
    canvasViewController.hashtagText = self.hashtagText;
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    [self updateSelectedTool];
}

- (void)setHashtagText:(NSString *)hashtagText
{
    _hashtagText = hashtagText;
    
    [self updateSelectedTool];
}

@end
