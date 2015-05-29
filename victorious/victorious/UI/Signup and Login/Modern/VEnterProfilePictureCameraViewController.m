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

#import "VLoginFlowControllerResponder.h"

// Dependencies
#import "VDependencyManager.h"
#import "VDependencyManager+VWorkspace.h"

// Camera + Workspace
#import "VWorkspaceFlowController.h"
#import "VImageToolController.h"

static NSString * const kPromptKey = @"prompt";

@interface VEnterProfilePictureCameraViewController () <VWorkspaceFlowControllerDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) UIViewController *viewControllerCameraPresentedFrom;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (nonatomic, weak) IBOutlet UIButton *avatarButton;

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
    
    NSMutableAttributedString *attributedPrompt = [[NSMutableAttributedString alloc] initWithString:prompt
                                                                                         attributes:promptAttributes];

    self.promptLabel.attributedText = attributedPrompt;
}

#pragma mark - Target/Action

- (IBAction)addProfilePicture:(id)sender
{
    [self showCameraOnViewController:self];
}

- (void)userPressedDone
{
    id <VLoginFlowControllerResponder> flowController = [self.viewControllerCameraPresentedFrom targetForAction:@selector(setProfilePictureFilePath:)
                                                                                                     withSender:self];
    if (flowController == nil)
    {
        NSAssert(false, @"We need a flow controller for setting the profile picture!");
    }
    [flowController setProfilePictureFilePath:nil];
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
    id <VLoginFlowControllerResponder> flowController = [self.viewControllerCameraPresentedFrom targetForAction:@selector(setProfilePictureFilePath:)
                                                                                                     withSender:self];
    if (flowController == nil)
    {
        NSAssert(false, @"We need a flow controller for setting the profile picture!");
    }
    [flowController setProfilePictureFilePath:capturedMediaURL];
}

- (BOOL)shouldShowPublishForWorkspaceFlowController:(VWorkspaceFlowController *)workspaceFlowController
{
    return NO;
}

#pragma mark - Private Methods

- (void)showCameraOnViewController:(UIViewController *)viewController
{
    NSDictionary *addedDependencies = @{ VImageToolControllerInitialImageEditStateKey : @(VImageToolControllerInitialImageEditStateFilter),
                                         VWorkspaceFlowControllerContextKey : @(VWorkspaceFlowControllerContextProfileImage) };
    VWorkspaceFlowController *workspaceFlowController = [self.dependencyManager workspaceFlowControllerWithAddedDependencies:addedDependencies];
    workspaceFlowController.delegate = self;
    workspaceFlowController.videoEnabled = NO;
    self.viewControllerCameraPresentedFrom = viewController;
    [viewController presentViewController:workspaceFlowController.flowRootViewController
                                 animated:YES
                               completion:nil];
}

@end
