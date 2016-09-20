//
//  VBaseWorkspaceViewController.m
//  victorious
//
//  Created by Michael Sena on 12/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseWorkspaceViewController.h"
#import "VDependencyManager+VWorkspace.h"
#import "victorious-Swift.h"

// Views
#import "VCanvasView.h"
#import "UIImageView+Blurring.h"
#import "VRoundedBackgroundButton.h"

// Keyboard
#import "VKeyboardNotificationManager.h"

// Protocols
#import "VWorkspaceTool.h"

// ToolControllers
#import "VImageToolController.h"
#import "VVideoToolController.h"

// Video
#import "VVideoWorkspaceTool.h"
#import "VDependencyManager+VTracking.h"
#import "VDependencyManager+VTracking.h"

@import AVFoundation;

static NSString * const kTitleKey = @"title";
static CGFloat const kWorkspaceToolButtonSize = 44.0f;
static CGFloat const kInspectorToolDisabledAlpha = 0.3f;
static CGFloat const kMinimumToolViewHeight = 100.0f;

@interface VBaseWorkspaceViewController ()

@property (nonatomic, strong, readwrite) NSURL *renderedMediaURL;

@property (nonatomic, strong, readwrite) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic, weak) IBOutlet VCanvasView *canvasView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *verticalSpaceCanvasToTopOfContainerConstraint;
@property (nonatomic, strong) NSArray *workspaceToolButtons;

@property (nonatomic, strong) NSMutableArray *inspectorConstraints;

@property (nonatomic, strong) UIViewController *inspectorToolViewController;

@property (nonatomic, strong) VKeyboardNotificationManager *keyboardManager;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceBottomBarToContainer;

@property (nonatomic, strong) UIVisualEffectView *blurView;

@end

@implementation VBaseWorkspaceViewController

#pragma mark - VHasManagedDependencies

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *workspaceStoryboard = [UIStoryboard storyboardWithName:@"Workspace" bundle:nil];
    VBaseWorkspaceViewController *workspaceViewController = [workspaceStoryboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    workspaceViewController.dependencyManager = dependencyManager;
    return workspaceViewController;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIViewController

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
    titleLabel.text = [self.dependencyManager stringForKey:kTitleKey] ?: NSLocalizedString(@"Edit", nil);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.navigationItem.titleView = titleLabel;
    
    [self.continueButton setTitle:self.continueText];
    
    self.view.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    
    self.toolController.canvasView = self.canvasView;
    
    NSMutableArray *toolBarItems = [[NSMutableArray alloc] init];
    [toolBarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:nil
                                                                          action:nil]];
    
    NSMutableArray *workspaceToolButtons = [[NSMutableArray alloc] init];
    [self.toolController.tools enumerateObjectsUsingBlock:^(id <VWorkspaceTool> tool, NSUInteger idx, BOOL *stop)
     {
         VRoundedBackgroundButton *workspaceToolButton = [[VRoundedBackgroundButton alloc] initWithFrame:CGRectMake(0, 0, kWorkspaceToolButtonSize, kWorkspaceToolButtonSize)];
         workspaceToolButton.selectedColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
         workspaceToolButton.unselectedColor = [UIColor colorWithRed:40/255.0f green:45/255.0f blue:48/255.0f alpha:1.0f];
         workspaceToolButton.selected = NO;
         [workspaceToolButton setImage:[tool icon] forState:UIControlStateNormal];
         [workspaceToolButton setImage:[tool selectedIcon] forState:UIControlStateSelected];
         workspaceToolButton.associatedObjectForButton = tool;
         [workspaceToolButton addTarget:self action:@selector(selectedButton:) forControlEvents:UIControlEventTouchUpInside];
         [workspaceToolButtons addObject:workspaceToolButton];
         
         UIBarButtonItem *itemForTool = [[UIBarButtonItem alloc] initWithCustomView:workspaceToolButton];
         
         [toolBarItems addObject:itemForTool];
         itemForTool.tag = idx;
         
         if (tool != self.toolController.tools.lastObject)
         {
             UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                         target:nil
                                                                                         action:nil];
             fixedSpace.width = 20.0f;
             [toolBarItems addObject:fixedSpace];
         }
     }];
    self.workspaceToolButtons = [workspaceToolButtons copy];
    
    [toolBarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    self.bottomToolbar.items = toolBarItems;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dependencyManager trackViewWillAppear:self];
    
    [self.toolController setupDefaultTool];
    
    [self.workspaceToolButtons enumerateObjectsUsingBlock:^(VRoundedBackgroundButton *toolButton, NSUInteger idx, BOOL *stop)
     {
         if (self.toolController.selectedTool == toolButton.associatedObjectForButton)
         {
             [self setSelectedButton:toolButton];
             *stop = YES;
         }
     }];
    
    __weak typeof(self) welf = self;
    self.keyboardManager = [[VKeyboardNotificationManager alloc] initWithKeyboardWillShowBlock:^(CGRect keyboardFrameBegin, CGRect keyboardFrameEnd, NSTimeInterval animationDuration, UIViewAnimationCurve animationCurve)
                            {
                                
                                [welf keyboardWillShowWithFrameBegin:keyboardFrameBegin
                                                            frameEnd:keyboardFrameEnd
                                                   animationDuration:animationDuration
                                                      animationCurve:animationCurve];
                            }
                                                                                 willHideBlock:^(CGRect keyboardFrameBegin, CGRect keyboardFrameEnd, NSTimeInterval animationDuration, UIViewAnimationCurve animationCurve)
                            {
                                [welf keyboardWillHideWithFrameBegin:keyboardFrameBegin
                                                            frameEnd:keyboardFrameEnd
                                                   animationDuration:animationDuration
                                                      animationCurve:animationCurve];
                            }
                                                                          willChangeFrameBlock:nil];
    if (self.toolController.shouldBottomBarBeHidden)
    {
        self.bottomToolbar.items = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.dependencyManager trackViewWillDisappear:self];
    
    self.keyboardManager = nil;
}

- (void)callCompletionWithSuccess:(BOOL)success
                     previewImage:(UIImage *)previewImage
                 renderedMediaURL:(NSURL *)renderedMediaURL
{
    if (self.completionBlock != nil)
    {
        self.completionBlock(success, previewImage, renderedMediaURL);
    }
}

#pragma mark - Target/Action

- (IBAction)close:(id)sender
{
    if (self.shouldConfirmCancels)
    {
        [self confirmCancel];
    }
    else
    {
        self.completionBlock(NO, nil, nil);
    }
}
- (IBAction)publish:(id)sender
{
    self.keyboardManager.stopCallingHandlerBlocks = YES;
    [self publishContent];
}

- (void)selectedButton:(VRoundedBackgroundButton *)button
{
    self.toolController.selectedTool = button.associatedObjectForButton;
    [self setSelectedButton:button];
    
    NSDictionary *params = @{ VTrackingKeyName : self.toolController.selectedTool.title ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectWorkspaceTool parameters:params];
}

#pragma mark - Abstract overrides

- (void)confirmCancel
{
    // Implement in subclasses
}

- (void)publishContent
{
    // Implement in subclasses
}

#pragma mark - VWorkspaceToolControllerDelegate

- (void)addCanvasViewController:(UIViewController *)canvasViewController
{
    if (canvasViewController == nil)
    {
        return;
    }
    [self addToolViewController:canvasViewController];
    [self positionToolViewControllerOnCanvas:canvasViewController];
}

- (void)removeCanvasViewController:(UIViewController *)canvasViewControllerToRemove
{
    [self removeToolViewController:canvasViewControllerToRemove];
}

- (void)setInspectorViewController:(UIViewController *)inspectorViewController
{
    [self removeToolViewController:self.inspectorToolViewController];
    self.inspectorToolViewController = inspectorViewController;
    
    if (inspectorViewController == nil)
    {
        return;
    }
    inspectorViewController.view.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    [self addToolViewController:inspectorViewController];
    [self positionToolViewControllerOnInspector:inspectorViewController];
}

#pragma mark - Property Accessors

- (void)setContinueText:(NSString *)continueText
{
    _continueText = [continueText copy];
    
    [self.continueButton setTitle:continueText];
}

#pragma mark - Public Methods

- (void)bringBottomChromeOutOfView
{
    self.verticalSpaceBottomBarToContainer.constant = -CGRectGetHeight(self.bottomToolbar.frame);
    self.view.backgroundColor = [UIColor clearColor];
    [self.view layoutIfNeeded];
}

- (void)bringChromeIntoView
{
    self.verticalSpaceBottomBarToContainer.constant = 0.0f;
    
    [self.view layoutIfNeeded];
}

#pragma mark - Focus

- (void)gainedFocus
{
    if ([self.toolController.selectedTool respondsToSelector:@selector(setSelected:)])
    {
        [self.toolController.selectedTool setSelected:YES];
    }
}

- (void)lostFocus
{
    if ([self.toolController.selectedTool respondsToSelector:@selector(setSelected:)])
    {
        [self.toolController.selectedTool setSelected:NO];
    }
}

#pragma mark - Private Methods

- (void)keyboardWillShowWithFrameBegin:(CGRect)beginFrame
                              frameEnd:(CGRect)endFrame
                     animationDuration:(NSTimeInterval)animationDuration
                        animationCurve:(UIViewAnimationCurve)animationCurve
{
    CGRect keyboardEndFrame = [self.view convertRect:endFrame
                                            fromView:nil];
    CGRect overlap = CGRectIntersection(self.canvasView.frame, keyboardEndFrame);
    
    // We don't want the inspector to move here
    CGRect inspectorFrame = self.inspectorToolViewController.view.frame;
    if ( self.adjustsCanvasViewFrameOnKeyboardAppearance )
    {
        [self.inspectorConstraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop)
         {
             [self.view removeConstraint:constraint];
         }];
    }
    
    void (^animations)() = ^()
    {
        if ( self.disablesInpectorOnKeyboardAppearance )
        {
            self.inspectorToolViewController.view.userInteractionEnabled = NO;
            self.inspectorToolViewController.view.alpha = kInspectorToolDisabledAlpha;
        }
        
        if ( self.adjustsCanvasViewFrameOnKeyboardAppearance )
        {
            self.verticalSpaceCanvasToTopOfContainerConstraint.constant = -CGRectGetHeight(overlap) + [self.topLayoutGuide length];
            self.inspectorToolViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
            self.inspectorToolViewController.view.frame = inspectorFrame;
            [self.view layoutIfNeeded];
        }
    };
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:(animationCurve << 16)
                     animations:animations
                     completion:nil];
}

- (void)keyboardWillHideWithFrameBegin:(CGRect)beginFrame
                              frameEnd:(CGRect)endFrame
                     animationDuration:(NSTimeInterval)animationDuration
                        animationCurve:(UIViewAnimationCurve)animationCurve
{
    // Undo removing inspector constraints we did in willShowBlock
    self.inspectorToolViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.inspectorConstraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop)
     {
         if (![((UIView *)constraint.firstItem) isDescendantOfView:self.view] || ![((UIView *)constraint.secondItem) isDescendantOfView:self.view])
         {
             return;
         }
         [self.view addConstraint:constraint];
     }];
    
    void (^animations)() = ^()
    {
        if ( self.disablesInpectorOnKeyboardAppearance )
        {
            self.inspectorToolViewController.view.userInteractionEnabled = YES;
            self.inspectorToolViewController.view.alpha = 1.0f;
        }
        
        if ( self.adjustsCanvasViewFrameOnKeyboardAppearance )
        {
            self.verticalSpaceCanvasToTopOfContainerConstraint.constant = [self.topLayoutGuide length];
            [self.view layoutIfNeeded];
        }
    };
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:(animationCurve << 16)
                     animations:animations
                     completion:nil];
}

- (void)setSelectedButton:(VRoundedBackgroundButton *)button
{
    [self.workspaceToolButtons enumerateObjectsUsingBlock:^(VRoundedBackgroundButton *toolButton, NSUInteger idx, BOOL *stop)
     {
         toolButton.selected = NO;
     }];
    button.selected = YES;
}

- (void)removeToolViewController:(UIViewController *)toolViewController
{
    [toolViewController willMoveToParentViewController:nil];
    [toolViewController.view removeFromSuperview];
    [toolViewController removeFromParentViewController];
}

- (void)addToolViewController:(UIViewController *)viewController
{
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
}

- (void)positionToolViewControllerOnCanvas:(UIViewController *)toolViewController
{
    toolViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    // Prevent weird resizing if we are in an animation block.
    toolViewController.view.frame = self.canvasView.bounds;
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:toolViewController.view
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.canvasView
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0f
                                                              constant:0.0f],
                                [NSLayoutConstraint constraintWithItem:toolViewController.view
                                                             attribute:NSLayoutAttributeLeft
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.canvasView
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1.0f
                                                              constant:0.0f],
                                [NSLayoutConstraint constraintWithItem:toolViewController.view
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.canvasView
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1.0f
                                                              constant:0.0f],
                                [NSLayoutConstraint constraintWithItem:toolViewController.view
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.canvasView
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0f
                                                              constant:0.0f],
                                ]];
}

- (void)positionToolViewControllerOnInspector:(UIViewController *)toolViewController
{
    toolViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.inspectorConstraints = [[NSMutableArray alloc] init];
    [self.inspectorConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|[picker]|"
                                                                                           options:kNilOptions
                                                                                           metrics:nil
                                                                                             views:@{@"picker":toolViewController.view}]];
    
    // Add a lower priority constraint to fill difference between canvas and toolbar on bigger devices
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:toolViewController.view
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.canvasView
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0f
                                                                      constant:0.0f];
    topConstraint.priority = UILayoutPriorityDefaultHigh;
    
    NSDictionary *verticalMetrics = @{@"toolbarHeight":@(CGRectGetHeight(self.bottomToolbar.bounds)), @"minimumToolViewHeight":@(kMinimumToolViewHeight)};
    [self.inspectorConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[picker(>=minimumToolViewHeight)]-toolbarHeight-|"
                                                                                           options:kNilOptions
                                                                                           metrics:verticalMetrics
                                                                                             views:@{@"picker":toolViewController.view,
                                                                                                     @"canvas":self.canvasView}]];
    [self.inspectorConstraints addObject:topConstraint];
    [self.view addConstraints:self.inspectorConstraints];
}

@end
