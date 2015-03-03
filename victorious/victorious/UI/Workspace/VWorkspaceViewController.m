//
//  VWorkspaceViewController.m
//  victorious
//
//  Created by Michael Sena on 12/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWorkspaceViewController.h"

// Dependency Management
#import "VDependencyManager+VWorkspaceTool.h"

// Views
#import "VCanvasView.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIImageView+Blurring.h"
#import "UIAlertView+VBlocks.h"
#import "UIActionSheet+VBlocks.h"

// Keyboard
#import "VKeyboardNotificationManager.h"

// Protocols
#import "VWorkspaceTool.h"

// Rendering Utilities
#import "CIImage+VImage.h"
#import "NSURL+MediaType.h"

// ToolControllers
#import "VImageToolController.h"
#import "VVideoToolController.h"

// Video
#import "VVideoWorkspaceTool.h"

@import AVFoundation;

@interface VWorkspaceViewController () <VToolControllerDelegate>

@property (nonatomic, strong, readwrite) NSURL *renderedMediaURL;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UIToolbar *topToolbar;
@property (nonatomic, weak) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic, weak) IBOutlet VCanvasView *canvasView;
@property (nonatomic, weak) IBOutlet UIImageView *blurredBackgroundImageView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *verticalSpaceCanvasToTopOfContainerConstraint;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *continueButton;
@property (nonatomic, strong) NSMutableArray *inspectorConstraints;

@property (nonatomic, strong) UIViewController *inspectorToolViewController;

@property (nonatomic, strong) VKeyboardNotificationManager *keyboardManager;

@property (nonatomic, strong, readwrite) VToolController *toolController;

@property (nonatomic, strong) NSDictionary *toolForBarButtonItemMap;
@property (nonatomic, strong) NSDictionary *barButtonItemForToolMap;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceTopBarToContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceBottomBarToContainer;

@property (nonatomic, strong) UIVisualEffectView *blurView;

@end

@implementation VWorkspaceViewController

#pragma mark - VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *workspaceStoryboard = [UIStoryboard storyboardWithName:@"Workspace" bundle:nil];
    VWorkspaceViewController *workspaceViewController = [workspaceStoryboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    workspaceViewController.dependencyManager = dependencyManager;
    
    return workspaceViewController;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.continueButton setTitle:self.continueText];
    
    self.view.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    
    self.toolController.canvasView = self.canvasView;
    
    [self.blurredBackgroundImageView setBlurredImageWithClearImage:self.previewImage
                                                  placeholderImage:nil
                                                         tintColor:[[UIColor blackColor] colorWithAlphaComponent:0.5f]];
    
    NSMutableArray *toolBarItems = [[NSMutableArray alloc] init];
    [toolBarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:nil
                                                                          action:nil]];
    
    NSMutableDictionary *barButtonItemForToolMap = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *toolForBarButtonItemMap = [[NSMutableDictionary alloc] init];
    [self.toolController.tools enumerateObjectsUsingBlock:^(id <VWorkspaceTool> tool, NSUInteger idx, BOOL *stop)
    {
        UIBarButtonItem *itemForTool;
        if (![tool respondsToSelector:@selector(icon)])
        {
            itemForTool = [[UIBarButtonItem alloc] initWithTitle:tool.title
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(selectedBarButtonItem:)];
        }
        else if ([tool icon] != nil)
        {
            itemForTool = [[UIBarButtonItem alloc] initWithImage:[tool icon]
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(selectedBarButtonItem:)];
        }
        else
        {
            itemForTool = [[UIBarButtonItem alloc] initWithTitle:tool.title
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(selectedBarButtonItem:)];
        }
        
        itemForTool.tintColor = [UIColor whiteColor];
        [toolBarItems addObject:itemForTool];
        itemForTool.tag = idx;
        
        [barButtonItemForToolMap setObject:itemForTool
                                    forKey:[tool description]];
        [toolForBarButtonItemMap setObject:tool
                                    forKey:[itemForTool description]];
        
        if (tool != self.toolController.tools.lastObject)
        {
            UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                        target:nil
                                                                                        action:nil];
            fixedSpace.width = 20.0f;
            [toolBarItems addObject:fixedSpace];
        }
    }];
    self.toolForBarButtonItemMap = toolForBarButtonItemMap;
    self.barButtonItemForToolMap = barButtonItemForToolMap;
    
    [toolBarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    self.bottomToolbar.items = toolBarItems;
    
    if ([self.toolController isKindOfClass:[VImageToolController class]])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(canvasViewDidUpdateAsset:)
                                                     name:VCanvasViewAssetSizeBecameAvailableNotification
                                                   object:self.canvasView];
        [self.canvasView setSourceURL:self.mediaURL
                   withPreloadedImage:self.previewImage];
    }
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.toolController setupDefaultTool];
    [self setSelectedBarButtonItem:[self.barButtonItemForToolMap objectForKey:[self.toolController.selectedTool description]]];
    
    self.keyboardManager.stopCallingHandlerBlocks = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.keyboardManager.stopCallingHandlerBlocks = YES;
}

- (void)setMediaURL:(NSURL *)mediaURL
{
    _mediaURL = mediaURL;
    
    if ([mediaURL v_hasImageExtension])
    {
        VImageToolController *imageToolController = [[VImageToolController alloc] initWithTools:[self.dependencyManager workspaceTools]];
        NSNumber *initialImageEditStateNumber = [self.dependencyManager templateValueOfType:[NSNumber class] forKey:VImageToolControllerInitialImageEditStateKey];
        if (initialImageEditStateNumber != nil)
        {
             imageToolController.defaultImageTool = [initialImageEditStateNumber integerValue];
        }
        self.toolController = imageToolController;
    }
    else if ([mediaURL v_hasVideoExtension])
    {
        VVideoToolController *videoToolController = [[VVideoToolController alloc] initWithTools:[self.dependencyManager workspaceTools]];
        NSNumber *initialVideoEditStateValue = [self.dependencyManager numberForKey:VVideoToolControllerInitalVideoEditStateKey];
        if (initialVideoEditStateValue != nil)
        {
            videoToolController.defaultVideoTool = [initialVideoEditStateValue integerValue];
        }
        self.toolController = videoToolController;
    }
    __weak typeof(self) welf = self;
    self.toolController.canRenderAndExportChangeBlock = ^void(BOOL canRenderAndExport)
    {
        welf.continueButton.enabled = canRenderAndExport;
    };
    self.toolController.delegate = self;
}

#pragma mark - Target/Action

- (IBAction)close:(id)sender
{
    if (self.shouldConfirmCancels)
    {
        __weak typeof(self) welf = self;
        UIActionSheet *confirmExitActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"This will discard any content from the camera", @"")
                                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                                      onCancelButton:nil
                                                              destructiveButtonTitle:NSLocalizedString(@"Discard", nil)
                                                                 onDestructiveButton:^
                                                 {
                                                     welf.completionBlock(NO, nil, nil);
                                                 }
                                                          otherButtonTitlesAndBlocks:nil, nil];
        [confirmExitActionSheet showInView:self.view];
        return;
    }
    self.completionBlock(NO, nil, nil);
}

- (IBAction)publish:(id)sender
{
    MBProgressHUD *hudForView = [MBProgressHUD showHUDAddedTo:self.view
                                                     animated:YES];
    hudForView.labelText = NSLocalizedString(@"Rendering...", @"");
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidFinishWorkspaceEdits];
    
    __weak typeof(self) welf = self;
    [self.toolController exportWithSourceAsset:self.mediaURL
                                withCompletion:^(BOOL finished, NSURL *renderedMediaURL, UIImage *previewImage, NSError *error)
     {
         [hudForView hide:YES];
         if (error != nil)
         {
             UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Render failure", @"")
                                                                  message:error.localizedDescription
                                                        cancelButtonTitle:NSLocalizedString(@"ok", @"")
                                                           onCancelButton:nil
                                               otherButtonTitlesAndBlocks:nil, nil];
             [errorAlert show];
         }
         else
         {
             if (welf.completionBlock != nil)
             {
                 welf.completionBlock(YES, previewImage, renderedMediaURL);
             }
         }
     }];
}

- (void)selectedBarButtonItem:(UIBarButtonItem *)sender
{
    self.toolController.selectedTool = [self.toolForBarButtonItemMap objectForKey:sender.description];
    [self setSelectedBarButtonItem:sender];
    
    NSDictionary *params = @{ VTrackingKeyName : self.toolController.selectedTool.title ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectWorkspaceTool parameters:params];
}

#pragma mark - Notification Handlers

- (void)canvasViewDidUpdateAsset:(NSNotification *)notification
{
    [self.blurredBackgroundImageView setBlurredImageWithClearImage:self.canvasView.asset
                                                  placeholderImage:nil
                                                         tintColor:[[UIColor blackColor] colorWithAlphaComponent:0.5f]
                                                           animate:YES];
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

- (void)bringTopChromeOutOfView
{
    self.verticalSpaceTopBarToContainer.constant = -CGRectGetHeight(self.topToolbar.frame);
    self.blurredBackgroundImageView.alpha = 0.0f;
    self.view.backgroundColor = [UIColor clearColor];
    [self.view layoutIfNeeded];
}

- (void)bringBottomChromeOutOfView
{
    self.verticalSpaceBottomBarToContainer.constant = -CGRectGetHeight(self.bottomToolbar.frame);
    self.blurredBackgroundImageView.alpha = 0.0f;
    self.view.backgroundColor = [UIColor clearColor];
    [self.view layoutIfNeeded];
}

- (void)bringChromeIntoView
{
    self.verticalSpaceTopBarToContainer.constant = 0.0f;
    self.verticalSpaceBottomBarToContainer.constant = 0.0f;

    [self.view layoutIfNeeded];
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
    [self.inspectorConstraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop)
     {
         [self.view removeConstraint:constraint];
     }];
    
    void (^animations)() = ^()
    {
        self.verticalSpaceCanvasToTopOfContainerConstraint.constant = -CGRectGetHeight(overlap) + CGRectGetHeight(self.topToolbar.frame);
        self.inspectorToolViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
        self.inspectorToolViewController.view.frame = inspectorFrame;
        [self.topToolbar.items enumerateObjectsUsingBlock:^(UIBarButtonItem *item, NSUInteger idx, BOOL *stop)
         {
             [item setEnabled:NO];
         }];
        [self.view layoutIfNeeded];
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
         [self.view addConstraint:constraint];
     }];
    
    void (^animations)() = ^()
    {
        self.verticalSpaceCanvasToTopOfContainerConstraint.constant = CGRectGetHeight(self.topToolbar.frame);
        [self.view layoutIfNeeded];
        [self.topToolbar.items enumerateObjectsUsingBlock:^(UIBarButtonItem *item, NSUInteger idx, BOOL *stop)
         {
             [item setEnabled:YES];
         }];
    };
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:(animationCurve << 16)
                     animations:animations
                     completion:nil];
}

- (void)setSelectedBarButtonItem:(UIBarButtonItem *)item
{
    [self.bottomToolbar.items enumerateObjectsUsingBlock:^(UIBarButtonItem *item, NSUInteger idx, BOOL *stop)
    {
        item.tintColor = [UIColor whiteColor];
    }];
    item.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
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
    
    NSDictionary *verticalMetrics = @{@"toolbarHeight":@(CGRectGetHeight(self.bottomToolbar.bounds))};
    [self.inspectorConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[canvas][picker]-toolbarHeight-|"
                                                                                           options:kNilOptions
                                                                                           metrics:verticalMetrics
                                                                                             views:@{@"picker":toolViewController.view,
                                                                                                     @"canvas":self.canvasView}]];
    [self.view addConstraints:self.inspectorConstraints];
}

@end
