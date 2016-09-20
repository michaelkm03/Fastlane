//
//  VEnterProfilePictureCameraShimViewController.m
//  victorious
//
//  Created by Michael Sena on 5/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEnterProfilePictureCameraViewController.h"

// Libraries
@import CoreText;
@import AudioToolbox;

#import "VLoginFlowControllerDelegate.h"
#import "victorious-Swift.h"

// Dependencies
#import "VDependencyManager.h"
#import "VDependencyManager+VLoginAndRegistration.h"
#import "VDependencyManager+VBackgroundContainer.h"

// Camera + Workspace
#import "VEditProfilePicturePresenter.h"
#import "VPermissionCamera.h"
#import "VDependencyManager+VTracking.h"

@interface VEnterProfilePictureCameraViewController () <VBackgroundContainer, VLoginFlowScreen>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UILabel *promptLabel;
@property (nonatomic, weak) IBOutlet UIButton *avatarButton;
@property (nonatomic, weak) IBOutlet UIButton *addProfilePictureButton;
@property (nonatomic, readonly) BOOL isFinalRegistrationScreen;

@property (nonatomic, strong) VEditProfilePicturePresenter *profilePicturePresetner;

@property (nonatomic, assign) BOOL hasSelectedAvatar;

@end

@implementation VEnterProfilePictureCameraViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSBundle *bundleForClass = [NSBundle bundleForClass:self];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass(self)
                                                         bundle:bundleForClass];
    VEnterProfilePictureCameraViewController *enterProfileViewController = [storyboard instantiateInitialViewController];
    enterProfileViewController.dependencyManager = dependencyManager;
    return enterProfileViewController;
}

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dependencyManager trackViewWillAppear:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.dependencyManager trackViewWillDisappear:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.delegate configureFlowNavigationItemWithScreen:self];
    
    self.navigationItem.hidesBackButton = YES;
    
    self.avatarButton.imageView.image = [self.avatarButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.avatarButton.tintColor = [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    
    NSString *prompt = [self.dependencyManager stringForKey:VScreenPromptKey] ?: @"";
    [self setScreenPrompt:prompt];
    
    NSString *buttonPrompt = [self.dependencyManager stringForKey:VButtonPromptKey] ?: @"";
    [self setButtonPrompt:buttonPrompt];
    
    self.avatarButton.layer.cornerRadius = CGRectGetHeight(self.avatarButton.bounds) / 2;
    self.avatarButton.layer.masksToBounds = YES;
    
    [self.dependencyManager addBackgroundToBackgroundHost:self];
}

#pragma mark - VLoginFlowScreen

@synthesize delegate = _delegate;

- (BOOL)displaysAfterSocialRegistration
{
    NSNumber *value = [self.dependencyManager numberForKey:VDisplayWithSocialRegistration];
    return value.boolValue;
}

- (void)onContinue:(id)sender
{
    NSNumber *profileImageRequiredValue = [self.dependencyManager numberForKey:VDependencyManagerProfileImageRequiredKey];
    const BOOL isProfileImageRequired = (profileImageRequiredValue == nil) ? YES : [profileImageRequiredValue boolValue];
    
    if (isProfileImageRequired && !self.hasSelectedAvatar)
    {
        [self showAvatarValidationFailedAnimation];
    }
    else
    {
        [self.delegate continueRegistrationFlow];
    }
}

#pragma mark - Target/Action

- (IBAction)addProfilePicture:(id)sender
{
    [self showCameraOnViewController:self];
    [self unHighlight:nil];
}

- (IBAction)highlight:(id)sender
{
    self.avatarButton.highlighted = YES;
    self.addProfilePictureButton.highlighted = YES;
}

- (IBAction)unHighlight:(id)sender
{
    self.avatarButton.highlighted = NO;
    self.addProfilePictureButton.highlighted = NO;
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.view;
}

#pragma mark - Private Methods

- (void)setScreenPrompt:(NSString *)message
{
    NSDictionary *screenPromptTextAttributes = @{
                                                 NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerHeading1FontKey],
                                                 NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey]
                                                 };
    
    NSMutableAttributedString *attributedPrompt = [[NSMutableAttributedString alloc] initWithString:message
                                                                                         attributes:screenPromptTextAttributes];
    self.promptLabel.attributedText = attributedPrompt;
}

- (void)setButtonPrompt:(NSString *)message
{
    NSDictionary *buttonPromptTextAttributes = @{
                                                 NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerButton1FontKey],
                                                 NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey]
                                                 };
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:message
                                                                          attributes:buttonPromptTextAttributes];
    [self.addProfilePictureButton setAttributedTitle:attributedTitle
                                            forState:UIControlStateNormal];
}

- (void)showAvatarValidationFailedAnimation
{
    [UIView animateKeyframesWithDuration:0.55f
                                   delay:0.0f
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^
     {
         [UIView addKeyframeWithRelativeStartTime:0.0f
                                 relativeDuration:0.25f
                                       animations:^
          {
              self.avatarButton.transform = CGAffineTransformMakeScale(0.7f, 0.7f);
          }];
         [UIView addKeyframeWithRelativeStartTime:0.25f
                                 relativeDuration:0.5f
                                       animations:^
          {
              self.avatarButton.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
          }];
         [UIView addKeyframeWithRelativeStartTime:0.75f
                                 relativeDuration:0.25f
                                       animations:^
          {
              self.avatarButton.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
          }];
     }
                              completion:nil];
    
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

- (void)showCameraOnViewController:(UIViewController *)viewController
{
    BOOL shouldRequestPermissions = [self.dependencyManager numberForKey:VShouldRequestCameraPermissionsKey].boolValue;

    if (!shouldRequestPermissions)
    {
        [self authorizedShowCamera];
    }
    else
    {
        VPermissionCamera *cameraPermission = [[VPermissionCamera alloc] init];
        cameraPermission.shouldShowInitialPrompt = NO;
        [cameraPermission requestSystemPermissionWithCompletion:^(BOOL granted, VPermissionState state, NSError *error)
        {
            if (granted)
            {
                [self authorizedShowCamera];
            }
            else
            {
                // We don't have permissions just continue
                [self onContinue:nil];
            }
        }];
    }
}

- (void)authorizedShowCamera
{
    self.profilePicturePresetner = [[VEditProfilePicturePresenter alloc] initWithDependencyManager:self.dependencyManager];
    self.profilePicturePresetner.isRegistration = YES;
    __weak typeof(self) welf = self;
    self.profilePicturePresetner.resultHandler = ^void(BOOL success, UIImage *previewImage, NSURL *mediaURL)
    {
        __strong typeof(welf) strongSelf = welf;
        [strongSelf onProfilePictureSelectedWithSuccess:success previewImage:previewImage mediaURL:mediaURL];
    };
    [self.profilePicturePresetner presentOnViewController:self];
}

- (void)onProfilePictureSelectedWithSuccess:(BOOL)success previewImage:(UIImage *)previewImage mediaURL:(NSURL *)mediaURL
{
    if (success)
    {
        id <VLoginFlowControllerDelegate> flowController = [self targetForAction:@selector(setProfilePictureFilePath:)
                                                                      withSender:self];
        if (flowController == nil)
        {
            NSAssert(false, @"We need a flow controller for setting the profile picture!");
        }
        [flowController setProfilePictureFilePath:mediaURL];
        [self.avatarButton setImage:previewImage forState:UIControlStateNormal];
        [self updateUIForSuccessfulProfilePictureCapture];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateUIForSuccessfulProfilePictureCapture
{
    NSString *screenSuccessMessage = [self.dependencyManager stringForKey:VScreenSuccessMessageKey];
    if (screenSuccessMessage != nil)
    {
        [self setScreenPrompt:screenSuccessMessage];
    }
    
    NSString *buttonSuccessMessage = [self.dependencyManager stringForKey:VButtonSuccessMessageKey];
    if (buttonSuccessMessage != nil)
    {
        [self setButtonPrompt:buttonSuccessMessage];
    }
}

@end
