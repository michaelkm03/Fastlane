//
//  VTextWorkspaceTool.m
//  victorious
//
//  Created by Michael Sena on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTextTool.h"

// Picker
#import "VToolPicker.h"

// Interface
#import "VTextToolViewController.h"

// Depenedency Management
#import "VDependencyManager.h"
#import "VDependencyManager+VWorkspaceTool.h"

static NSString * const kTitleKey = @"title";
static NSString * const kIconKey = @"icon";
static NSString * const kSubtoolsKey = @"subtools";
static NSString * const kPickerKey = @"picker";
static NSString * const kFilterIndexKey = @"filterIndex";

@interface VTextTool ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSNumber *renderIndexNumber;
@property (nonatomic, strong) NSArray *subTools;
@property (nonatomic, strong) id <VWorkspaceTool> activeTextTool;
@property (nonatomic, strong) UIViewController <VToolPicker> *toolPicker;
@property (nonatomic, strong) VTextToolViewController *canvasToolViewController;

@end

@implementation VTextTool

#pragma mark - VHasManagedDependancies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _title = [dependencyManager stringForKey:kTitleKey];
        _subTools = [dependencyManager workspaceTools];
        _renderIndexNumber = [dependencyManager numberForKey:kFilterIndexKey];
        _toolPicker = (UIViewController<VToolPicker> *)[dependencyManager viewControllerForKey:kPickerKey];
        _canvasToolViewController = [VTextToolViewController textToolViewController];
        
        [(id<VToolPicker>)_toolPicker setTools:_subTools];
    }
    return self;
}

#pragma mark - Property Accessors

- (void)setActiveTextTool:(id<VWorkspaceTool>)activeTextTool
{
    if (activeTextTool == _activeTextTool)
    {
        return;
    }
    
    _activeTextTool = activeTextTool;
    
    if ([activeTextTool isKindOfClass:[VTextTypeTool class]])
    {
        self.canvasToolViewController.textType = (VTextTypeTool *)activeTextTool;
    }
}

#pragma mark - VWorkspaceTool

- (CIImage *)imageByApplyingToolToInputImage:(CIImage *)inputImage
{
    return inputImage;
}

- (NSInteger)renderIndex
{
    return [self.renderIndexNumber integerValue];
}

- (BOOL)shouldLeaveToolOnCanvas
{
    return YES;
}

- (UIViewController *)inspectorToolViewController
{
    __weak typeof(self) welf = self;
    self.toolPicker.onToolSelection = ^(id <VWorkspaceTool> selectedTool)
    {
        welf.activeTextTool = selectedTool;
    };
    return (UIViewController *)self.toolPicker;
}

@end
