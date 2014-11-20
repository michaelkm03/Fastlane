//
//  UIViewController+VNavMenu.m
//  victorious
//
//  Created by Will Long on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIViewController+VNavMenu.h"
#import "UIViewController+VSideMenuViewController.h"

#import <objc/runtime.h>

//Create Sequence import
#import "VSettingManager.h"
#import "VObjectManager+Login.h"
#import "VCameraViewController.h"
#import "VCameraPublishViewController.h"
#import "VCreatePollViewController.h"
#import "VAuthorizationViewControllerFactory.h"
#import "UIActionSheet+VBlocks.h"
#import "VAccessibilityConstants.h"

static const char kNavHeaderViewKey;
static const char kNavHeaderYConstraintKey;
static const char kUploadProgressVCKey;
static const char kUploadProgressYConstraintKey;

@interface UIViewController (VNavMenuPrivate)

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
        self.navHeaderView = [VNavigationHeaderView menuButtonNavHeaderWithControlTitles:titles];
    }
    else
    {
        self.navHeaderView = [VNavigationHeaderView backButtonNavHeaderWithControlTitles:titles];
        
    }
    
    self.navHeaderView.headerText = self.title;//Set the title in case there is no logo
    [self.navHeaderView updateUIForVC:self];
    [self.view addSubview:self.navHeaderView];
    
    self.navHeaderYConstraint = [NSLayoutConstraint constraintWithItem:self.navHeaderView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0f
                                                           constant:0.0f];
    [self.view addConstraint:self.navHeaderYConstraint];
    
    VNavigationHeaderView *header = self.navHeaderView;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[header]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(header)]];
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
    button.accessibilityIdentifier = kVAccessibilityIdAddPost;

}

- (IBAction)createSequenceAction:(id)sender
{
    if (![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    cancelButtonTitle:NSLocalizedString(@"CancelButton", @"Cancel button")
                                                       onCancelButton:nil
                                               destructiveButtonTitle:nil
                                                  onDestructiveButton:nil
                                           otherButtonTitlesAndBlocks:
                                  NSLocalizedString(@"Create a Video Post", @""), ^(void)
                                  {
                                      [self presentCameraViewController:[VCameraViewController cameraViewController]];
                                  },
                                  NSLocalizedString(@"Create an Image Post", @""), ^(void)
                                  {
                                      [self presentCameraViewController:[VCameraViewController cameraViewControllerStartingWithStillCapture]];
                                  },
                                  NSLocalizedString(@"Create a Poll", @""), ^(void)
                                  {
                                      VCreatePollViewController *createViewController = [VCreatePollViewController newCreatePollViewController];
                                      [self.navigationController pushViewController:createViewController animated:YES];
                                  }, nil];
    [actionSheet showInView:self.view];
}

- (void)presentCameraViewController:(VCameraViewController *)cameraViewController
{
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    UINavigationController *__weak weakNav = navigationController;
    cameraViewController.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        if (!finished || !capturedMediaURL)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            VCameraPublishViewController *publishViewController = [VCameraPublishViewController cameraPublishViewController];
            publishViewController.previewImage = previewImage;
            publishViewController.mediaURL = capturedMediaURL;
            publishViewController.completion = ^(BOOL complete)
            {
                if (complete)
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                else
                {
                    [weakNav popViewControllerAnimated:YES];
                }
            };
            [weakNav pushViewController:publishViewController animated:YES];
        }
    };
    [navigationController pushViewController:cameraViewController animated:NO];
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end
