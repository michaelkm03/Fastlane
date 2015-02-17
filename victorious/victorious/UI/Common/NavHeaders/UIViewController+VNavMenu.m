//
//  UIViewController+VNavMenu.m
//  victorious
//
//  Created by Will Long on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import MobileCoreServices;

#import "UIViewController+VNavMenu.h"
#import "UIViewController+VSideMenuViewController.h"

// Dependency Management
#import "VHasManagedDependencies.h"
#import "VDependencyManager.h"

// Runtime
#import <objc/runtime.h>

//Create Sequence import
#import "VSettingManager.h"
#import "VObjectManager+Login.h"
#import "VCreatePollViewController.h"
#import "VAuthorizationViewControllerFactory.h"
#import "VAlertController.h"
#import "VThemeManager.h"
#import "UIActionSheet+VBlocks.h"
#import "VAutomation.h"
#import "VWorkspaceFlowController.h"
#import "VPublishViewController.h"

static const char kNavHeaderViewKey;
static const char kNavHeaderYConstraintKey;
static const char kUploadProgressVCKey;
static const char kUploadProgressYConstraintKey;
static const char kWorkspaceFlowControllerKey;

@interface UIViewController (VNavMenuPrivate) <VWorkspaceFlowControllerDelegate>

@property (nonatomic, strong) NSLayoutConstraint *navHeaderYConstraint;
@property (nonatomic, strong) NSLayoutConstraint *uploadProgressViewYconstraint;

@end

@implementation UIViewController (VNavMenu)

#pragma mark - Header

- (void)setUploadProgressViewController:(VUploadProgressViewController *)uploadProgressViewController
{
    [self.uploadProgressViewController willMoveToParentViewController:nil];
    [self.uploadProgressViewController.view removeFromSuperview];
    [self.uploadProgressViewController removeFromParentViewController];
    [self addChildViewController:uploadProgressViewController];
    [self.view addSubview:uploadProgressViewController.view];
    [uploadProgressViewController didMoveToParentViewController:self];
    objc_setAssociatedObject(self, &kUploadProgressVCKey, uploadProgressViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (VUploadProgressViewController *)uploadProgressViewController
{
    VUploadProgressViewController *uploadProgressViewController = objc_getAssociatedObject(self, &kUploadProgressVCKey);
    return uploadProgressViewController;
}

- (void)setUploadProgressViewYconstraint:(NSLayoutConstraint *)uploadProgressViewYconstraint
{
    objc_setAssociatedObject(self, &kUploadProgressYConstraintKey, uploadProgressViewYconstraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSLayoutConstraint *)uploadProgressViewYconstraint
{
    NSLayoutConstraint *uploadProgressViewYconstraint = objc_getAssociatedObject(self, &kUploadProgressYConstraintKey);
    return uploadProgressViewYconstraint;
}

- (void)setNavHeaderView:(VNavigationHeaderView *)navHeaderView
{
    [self.navHeaderView removeFromSuperview];
    objc_setAssociatedObject(self, &kNavHeaderViewKey, navHeaderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (VNavigationHeaderView *)navHeaderView
{
    VNavigationHeaderView *navHeaderView = objc_getAssociatedObject(self, &kNavHeaderViewKey);
    return navHeaderView;
}

- (void)setNavHeaderYConstraint:(NSLayoutConstraint *)navHeaderYConstraint
{
    objc_setAssociatedObject(self, &kNavHeaderYConstraintKey, navHeaderYConstraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSLayoutConstraint *)navHeaderYConstraint
{
    NSLayoutConstraint *navHeaderYConstraint = objc_getAssociatedObject(self, &kNavHeaderYConstraintKey);
    return navHeaderYConstraint;
}

- (void)v_addNewNavHeaderWithTitles:(NSArray *)titles
{
    if (self.navigationController.viewControllers.count <= 1)
    {
        self.navHeaderView = [VNavigationHeaderView menuButtonNavHeader];
    }
    else
    {
        self.navHeaderView = [VNavigationHeaderView backButtonNavHeader];
    }
    
    self.navHeaderView.headerText = self.title; //Set the title in case there is no logo
    [self.navHeaderView updateUIForVC:self];
    
    self.navHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.navHeaderView];
    
    VNavigationHeaderView *header = self.navHeaderView;
    NSArray *constraintsV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[header]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:NSDictionaryOfVariableBindings(header)];
    self.navHeaderYConstraint = constraintsV.firstObject;
    [self.view addConstraints:constraintsV];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[header]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(header)]];
    
    [self.navHeaderView setupSegmentedControlWithTitles:titles];
}

- (void)v_hideHeader
{
    if (!CGRectContainsRect(self.view.frame, self.navHeaderView.frame))
    {
        return;
    }
    
    self.navHeaderYConstraint.constant = -CGRectGetHeight(self.navHeaderView.frame);
    [self.view layoutIfNeeded];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)v_showHeader
{
    if (CGRectContainsRect(self.view.frame, self.navHeaderView.frame))
    {
        return;
    }
    
    self.navHeaderYConstraint.constant = 0;
    [self.view layoutIfNeeded];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)backPressedOnNavHeader:(VNavigationHeaderView *)navHeaderView
{
    if (navHeaderView == self.navHeaderView)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)menuPressedOnNavHeader:(VNavigationHeaderView *)navHeaderView
{
    if (navHeaderView == self.navHeaderView)
    {
        [self.sideMenuViewController presentMenuViewController];
    }
}

#pragma mark - Upload Progress View

- (void)v_addUploadProgressView
{
    self.uploadProgressViewController = [VUploadProgressViewController viewControllerForUploadManager:[[VObjectManager sharedManager] uploadManager]];
    [self addChildViewController:self.uploadProgressViewController];
    self.uploadProgressViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:self.uploadProgressViewController.view belowSubview:self.navHeaderView];
    [self.uploadProgressViewController didMoveToParentViewController:self];
    
    UIView *upvc = self.uploadProgressViewController.view;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[upvc]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(upvc)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:upvc
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0f
                                                           constant:VUploadProgressViewControllerIdealHeight]];
    
    self.uploadProgressViewYconstraint = [NSLayoutConstraint constraintWithItem:upvc
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.navHeaderView
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1.0f
                                                                       constant:-VUploadProgressViewControllerIdealHeight];
    [self.view addConstraint:self.uploadProgressViewYconstraint];
    
    if (self.uploadProgressViewController.numberOfUploads)
    {
        [self v_showUploads];
    }
}

- (void)v_showUploads
{
    self.uploadProgressViewYconstraint.constant = 0;
}

- (BOOL)isUploadProgressVisible
{
    return self.uploadProgressViewController != nil && self.uploadProgressViewYconstraint.constant == 0;
}

- (void)v_hideUploads
{
    self.uploadProgressViewYconstraint.constant = -VUploadProgressViewControllerIdealHeight;
}

#pragma mark - Create Sequence action

- (void)v_addCreateSequenceButton
{
    BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];

    UIImage *image = isTemplateC ? [UIImage imageNamed:@"createContentButtonC"] : [UIImage imageNamed:@"createContentButton"];
    UIButton *button = [self.navHeaderView setRightButtonImage:image
                                 withAction:@selector(createSequenceAction:)
                                                      onTarget:self];
    button.accessibilityIdentifier = VAutomationIdentifierAddPost;

}

- (IBAction)createSequenceAction:(id)sender
{
    if (![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return;
    }
    
    [self showContentTypeSelection];
}

- (void)showContentTypeSelection
{
    VAlertController *alertControler = [VAlertController actionSheetWithTitle:nil message:nil];
    [alertControler addAction:[VAlertAction cancelButtonWithTitle:NSLocalizedString(@"CancelButton", @"Cancel button") handler:nil]];
    [alertControler addAction:[VAlertAction buttonWithTitle:NSLocalizedString(@"Create a Video Post", @"") handler:^(VAlertAction *action)
                               {
                                   [self presentCreateFlowWithInitialCaptureState:VWorkspaceFlowControllerInitialCaptureStateVideo];
                               }]];
    [alertControler addAction:[VAlertAction buttonWithTitle:NSLocalizedString(@"Create an Image Post", @"") handler:^(VAlertAction *action)
                               {
                                   [self presentCreateFlowWithInitialCaptureState:VWorkspaceFlowControllerInitialCaptureStateImage];
                               }]];
    [alertControler addAction:[VAlertAction buttonWithTitle:NSLocalizedString(@"Create a GIF", @"Create a gif action button.")
                                                    handler:^(VAlertAction *action)
                               {
                                   [self presentCreateFlowWithInitialCaptureState:VWorkspaceFlowControllerInitialCaptureStateVideo
                                                            initialImageEditState:VImageToolControllerInitialImageEditStateText
                                                         andInitialVideoEditState:VVideoToolControllerInitialVideoEditStateGIF];
                               }]];
    [alertControler addAction:[VAlertAction buttonWithTitle:NSLocalizedString(@"Create a Poll", @"") handler:^(VAlertAction *action)
                               {
                                   VCreatePollViewController *createViewController = [VCreatePollViewController newCreatePollViewController];
                                   [self.navigationController pushViewController:createViewController animated:YES];
                               }]];
    [alertControler presentInViewController:self animated:YES completion:nil];
}

- (void)presentCreateFlowWithInitialCaptureState:(VWorkspaceFlowControllerInitialCaptureState)initialCaptureState
                           initialImageEditState:(VImageToolControllerInitialImageEditState)initialImageEdit
                        andInitialVideoEditState:(VVideoToolControllerInitialVideoEditState)initialVideoEdit
{
    VDependencyManager *dependencyManager = [(id)self dependencyManager];
    
    VWorkspaceFlowController *workspaceFlowController = [dependencyManager templateValueOfType:[VWorkspaceFlowController class]
                                                                   forKey:VDependencyManagerWorkspaceFlowKey
                                                    withAddedDependencies:@{VWorkspaceFlowControllerInitialCaptureStateKey:@(initialCaptureState),
                                                                            VImageToolControllerInitialImageEditStateKey:@(initialImageEdit),
                                                                            VVideoToolControllerInitalVideoEditStateKey:@(initialVideoEdit)}];
    workspaceFlowController.delegate = self;
    workspaceFlowController.videoEnabled = YES;
    [self presentViewController:workspaceFlowController.flowRootViewController
                       animated:YES
                     completion:nil];
}

- (void)presentCreateFlowWithInitialCaptureState:(VWorkspaceFlowControllerInitialCaptureState)initialCaptureState
{
    [self presentCreateFlowWithInitialCaptureState:initialCaptureState
                             initialImageEditState:VImageToolControllerInitialImageEditStateText
                          andInitialVideoEditState:VVideoToolControllerInitialVideoEditStateVideo];
}

- (CGFloat)headerPositionY
{
    return self.navHeaderYConstraint.constant;
}

- (void)setWorkspaceFlowController:(VWorkspaceFlowController *)workspaceFlowController
{
    objc_setAssociatedObject(self, &kWorkspaceFlowControllerKey, workspaceFlowController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (VWorkspaceFlowController *)workspaceFlowController
{
    return objc_getAssociatedObject(self, &kWorkspaceFlowControllerKey);
}

#pragma mark - VWorkspaceFlowControllerDelegate

- (void)workspaceFlowControllerDidCancel:(VWorkspaceFlowController *)workspaceFlowController
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)workspaceFlowController:(VWorkspaceFlowController *)workspaceFlowController finishedWithPreviewImage:(UIImage *)previewImage capturedMediaURL:(NSURL *)capturedMediaURL
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end
