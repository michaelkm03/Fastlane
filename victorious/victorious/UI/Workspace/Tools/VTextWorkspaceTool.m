//
//  VTextTool.m
//  victorious
//
//  Created by Michael Sena on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTextWorkspaceTool.h"
#import "VMemeWorkspaceToolViewController.h"
#import "VToolPicker.h"

#import "VDependencyManager.h"
#import "VDependencyManager+VWorkspaceTool.h"

static NSString * const kTitleKey = @"title";
static NSString * const kIconKey = @"icon";
static NSString * const kSubtoolsKey = @"subtools";
static NSString * const kPickerKey = @"picker";

@interface VTextWorkspaceTool ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSArray *subTools;
@property (nonatomic, strong) UIViewController <VToolPicker> *toolPicker;
@property (nonatomic, strong) UIViewController *activeTextTool;

@end

@implementation VTextWorkspaceTool

@synthesize onCanvasToolUpdate;

#pragma mark - VHasManagedDependancies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _title = [dependencyManager stringForKey:kTitleKey];
        _subTools = [dependencyManager tools];
        _toolPicker = (UIViewController<VToolPicker> *)[dependencyManager viewControllerForKey:kPickerKey];
        [(id<VToolPicker>)_toolPicker setTools:_subTools];
    }
    return self;
}

#pragma mark - VWorkspaceTool

- (BOOL)shouldLeaveToolOnCanvas
{
    return YES;
}

- (UIViewController *)canvasToolViewController
{
    return _activeTextTool;
}

- (UIViewController *)inspectorToolViewController
{
    __weak typeof(self) welf = self;
    self.toolPicker.onToolSelection = ^(id <VWorkspaceTool> selectedTool)
    {
        if (![selectedTool respondsToSelector:@selector(canvasToolViewController)])
        {
            return;
        }
        welf.activeTextTool = [selectedTool canvasToolViewController];
        if (welf.onCanvasToolUpdate)
        {
            welf.onCanvasToolUpdate();
        }
    };
    return (UIViewController *)self.toolPicker;
}

- (NSString *)title
{
    return _title;
}

@end
