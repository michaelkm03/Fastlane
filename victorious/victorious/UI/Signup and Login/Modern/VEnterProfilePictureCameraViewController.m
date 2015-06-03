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

#import "VLoginFlowControllerResponder.h"

// Dependencies
#import "VDependencyManager.h"
#import "VDependencyManager+VWorkspace.h"

// Camera + Workspace
#import "VWorkspaceFlowController.h"
#import "VImageToolController.h"

static NSString * const kPromptKey = @"prompt";
static NSString * const kButtonPromptKey = @"buttonPrompt";

@interface VEnterProfilePictureCameraViewController () <VWorkspaceFlowControllerDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UILabel *promptLabel;
@property (nonatomic, weak) IBOutlet UIButton *avatarButton;
@property (nonatomic, weak) IBOutlet UIButton *addProfilePictureButton;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(userPressedDone)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.hidesBackButton = YES;
    
    self.avatarButton.imageView.image = [self.avatarButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.avatarButton.tintColor = [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    
    NSString *prompt = [self.dependencyManager stringForKey:kPromptKey] ?: @"";
    NSDictionary *promptAttributes = @{
                                       NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerHeading1FontKey],
                                       NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey]
                                       };
    
    NSMutableAttributedString *attributedPrompt = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(prompt, nil)
                                                                                         attributes:promptAttributes];

    self.promptLabel.attributedText = attributedPrompt;
    NSDictionary *addProfileTextAttributes = @{
                                               NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerButton1FontKey],
                                               NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey],
                                               };
    NSString *buttonPrompt = [self.dependencyManager stringForKey:kButtonPromptKey] ?: @"";
    NSAttributedString *addProfilePictureButtonTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(buttonPrompt, nil)
                                                                                  attributes:addProfileTextAttributes];
    [self.addProfilePictureButton setAttributedTitle:addProfilePictureButtonTitle
                                            forState:UIControlStateNormal];
    
    self.avatarButton.layer.cornerRadius = CGRectGetHeight(self.avatarButton.bounds) / 2;
    self.avatarButton.layer.masksToBounds = YES;
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

- (void)userPressedDone
{
    NSNumber *profileImageRequiredValue = [self.dependencyManager numberForKey:VDependencyManagerProfileImageRequiredKey];
    const BOOL isProfileImageRequired = (profileImageRequiredValue == nil) ? YES : [profileImageRequiredValue boolValue];
    
    if (isProfileImageRequired && !self.hasSelectedAvatar)
    {
        [self showAvatarValidationFailedAnimation];
    }
    else
    {
        id <VLoginFlowControllerResponder> flowController = [self targetForAction:@selector(continueRegistrationFlow)
                                                                       withSender:self];
        if (flowController == nil)
        {
            NSAssert(false, @"We need a flow controller for finishing profile creation.");
        }
        [flowController continueRegistrationFlow];
    }
}

#pragma mark - VWorkspaceFlowControllerDelegate

- (void)workspaceFlowControllerDidCancel:(VWorkspaceFlowController *)workspaceFlowController
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)workspaceFlowController:(VWorkspaceFlowController *)workspaceFlowController
       finishedWithPreviewImage:(UIImage *)previewImage
               capturedMediaURL:(NSURL *)capturedMediaURL
{
    self.hasSelectedAvatar = YES;
    [self dismissViewControllerAnimated:YES
                             completion:^
     {
         id <VLoginFlowControllerResponder> flowController = [self targetForAction:@selector(setProfilePictureFilePath:)
                                                                        withSender:self];
         if (flowController == nil)
         {
             NSAssert(false, @"We need a flow controller for setting the profile picture!");
         }
         [flowController setProfilePictureFilePath:capturedMediaURL];
         [self.avatarButton setImage:previewImage forState:UIControlStateNormal];
     }];
}

- (BOOL)shouldShowPublishForWorkspaceFlowController:(VWorkspaceFlowController *)workspaceFlowController
{
    return NO;
}

#pragma mark - Private Methods

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
    NSDictionary *addedDependencies = @{ VImageToolControllerInitialImageEditStateKey : @(VImageToolControllerInitialImageEditStateFilter),
                                         VWorkspaceFlowControllerContextKey : @(VWorkspaceFlowControllerContextProfileImage) };
    VWorkspaceFlowController *workspaceFlowController = [self.dependencyManager workspaceFlowControllerWithAddedDependencies:addedDependencies];
    workspaceFlowController.delegate = self;
    workspaceFlowController.videoEnabled = NO;
    [viewController presentViewController:workspaceFlowController.flowRootViewController
                                 animated:YES
                               completion:nil];
}

@end
