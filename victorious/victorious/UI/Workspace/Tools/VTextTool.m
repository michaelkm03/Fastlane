//
//  VTextWorkspaceTool.m
//  victorious
//
//  Created by Michael Sena on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTextTool.h"
#import "VMemeWorkspaceToolViewController.h"
#import "VToolPicker.h"

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
@property (nonatomic, strong) UIViewController *activeTextToolViewController;
@property (nonatomic, strong) UIViewController <VToolPicker> *toolPicker;
@property (nonatomic, strong) UIViewController *canvasTextContainer;

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
    
    // Swap childrenVCs
    if (self.activeTextToolViewController != nil)
    {
        [self.activeTextToolViewController willMoveToParentViewController:nil];
        [self.activeTextToolViewController.view removeFromSuperview];
        [self.activeTextToolViewController removeFromParentViewController];
    }
    
    if ([activeTextTool canvasToolViewController] != nil)
    {
        [self.canvasTextContainer addChildViewController:[activeTextTool canvasToolViewController]];
        [self.canvasTextContainer.view addSubview:[activeTextTool canvasToolViewController].view];
        [[activeTextTool canvasToolViewController] didMoveToParentViewController:self.canvasTextContainer];
        
        [self positionActiveTool:[activeTextTool canvasToolViewController].view];
    }
    
    _activeTextTool = activeTextTool;
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

- (UIViewController *)canvasToolViewController
{
    return self.canvasTextContainer;
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
        welf.activeTextTool = selectedTool;
    };
    return (UIViewController *)self.toolPicker;
}

#pragma mark - Internal Methods

- (void)positionActiveTool:(UIView *)viewForActiveTool
{
    viewForActiveTool.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewMap = @{@"viewForActiveTool":viewForActiveTool};
    [self.canvasTextContainer.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[viewForActiveTool]|"
                                                                                          options:kNilOptions
                                                                                          metrics:nil
                                                                                            views:viewMap]];
    [self.canvasTextContainer.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[viewForActiveTool]|"
                                                                                          options:kNilOptions
                                                                                          metrics:nil
                                                                                            views:viewMap]];
}

- (UIViewController *)canvasTextContainer
{
    if (_canvasTextContainer != nil)
    {
        return _canvasTextContainer;
    }

    _canvasTextContainer = [[UIViewController alloc] initWithNibName:nil
                                                              bundle:nil];
    _canvasTextContainer.view = [[UIView alloc] initWithFrame:CGRectZero];
    _canvasTextContainer.view.backgroundColor = [UIColor clearColor];
    return _canvasTextContainer;
}

@end
