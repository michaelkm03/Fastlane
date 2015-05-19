//
//  VProfileEditViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractProfileEditViewController.h"
#import "VWorkspaceFlowController.h"
#import "VImageToolController.h"
#import "VUser.h"
#import "UIImageView+Blurring.h"
#import "UIImage+ImageEffects.h"
#import "VContentInputAccessoryView.h"
#import "VConstants.h"
#import "VNavigationController.h"
#import "VDependencyManager+VWorkspace.h"
#import "VTemplateBackgroundView.h"
#import "VDefaultProfileImageView.h"
#import "UIImageView+VLoadingAnimations.h"
#import <SDWebImage/UIImageView+WebCache.h>

static const CGFloat kTextColor = 0.355f;
static const CGFloat kPlaceholderAlpha = 0.3f;
static const CGFloat kBlurredWhiteAlpha = 0.3f;

@interface VAbstractProfileEditViewController () <VContentInputAccessoryViewDelegate, VWorkspaceFlowControllerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *tagLinePlaceholderLabel;
@property (nonatomic, weak) IBOutlet VDefaultProfileImageView *profileImageView;
@property (nonatomic, weak) IBOutlet UIButton *cameraButton;

@property (nonatomic, weak) IBOutlet UITableViewCell *captionCell;
@property (nonatomic, assign) NSInteger numberOfLines;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceTaglineTextViewTopToContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceTaglineTextViewBottomToContainer;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VAbstractProfileEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.usernameTextField.delegate = self;
    self.locationTextField.delegate = self;
    self.taglineTextView.delegate = self;
    
    self.cameraButton.layer.masksToBounds = YES;
    self.cameraButton.layer.cornerRadius = CGRectGetHeight(self.cameraButton.bounds)/2;
    self.cameraButton.clipsToBounds = YES;
    
    self.taglineTextView.inputAccessoryView =
    ({
        VContentInputAccessoryView *inputAccessoryView = [[VContentInputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44.0f)];
        inputAccessoryView.delegate = self;
        inputAccessoryView.textInputView = self.taglineTextView;
        inputAccessoryView.tintColor = [UIColor colorWithRed:0.85f green:0.86f blue:0.87f alpha:1.0f];
        inputAccessoryView;
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self applySyle];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.usernameTextField becomeFirstResponder];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)v_prefersNavigationBarHidden
{
    return NO;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:[NSIndexPath indexPathForRow:3 inSection:0]])
    {
        return [self.taglineTextView sizeThatFits:CGSizeMake(CGRectGetWidth(self.taglineTextView.bounds), FLT_MAX)].height + ABS(self.verticalSpaceTaglineTextViewBottomToContainer.constant) + ABS(self.verticalSpaceTaglineTextViewTopToContainer.constant);
    }
    return [super tableView:tableView
    heightForRowAtIndexPath:indexPath];
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    [self applySyle];
}

#pragma mark - Private Methods

- (void)applySyle
{
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.layer.cornerRadius = CGRectGetHeight(self.profileImageView.bounds)/2;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.borderWidth = 2.0;
    self.profileImageView.layer.borderColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey].CGColor;
    self.profileImageView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.profileImageView.backgroundColor = [UIColor whiteColor];
    
    self.usernameTextField.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.usernameTextField.textColor = [UIColor colorWithWhite:kTextColor alpha:1.0f];
    self.usernameTextField.font = [self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
    self.locationTextField.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.locationTextField.textColor = [UIColor colorWithWhite:kTextColor alpha:1.0f];
    self.locationTextField.font = [self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
    self.taglineTextView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.taglineTextView.textColor = [UIColor colorWithWhite:kTextColor alpha:1.0f];
    self.taglineTextView.font = [self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
    self.tagLinePlaceholderLabel.textColor = [UIColor colorWithWhite:kTextColor alpha:kPlaceholderAlpha];
    self.tagLinePlaceholderLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
}

#pragma mark - Property Accessors

- (void)setProfile:(VUser *)profile
{
    NSAssert([NSThread isMainThread], @"");
    _profile = profile;
 
    self.usernameTextField.text = profile.name;
    self.taglineTextView.text = profile.tagline;
    self.locationTextField.text = profile.location;
    
    self.tagLinePlaceholderLabel.hidden = (profile.tagline.length > 0);
    
    // Create background image
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.tableView.backgroundView.frame];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundView = backgroundImageView;
    self.backgroundImageView = backgroundImageView;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    // Set profile images
    NSURL *profileImageURL = [NSURL URLWithString:profile.pictureUrl];
    if ( profileImageURL != nil && profile.pictureUrl.length > 0 )
    {
        [backgroundImageView applyTintAndBlurToImageWithURL:profileImageURL
                                              withTintColor:[UIColor colorWithWhite:1.0 alpha:kBlurredWhiteAlpha]];
        [self.profileImageView setProfileImageURL:profileImageURL];
    }
    else
    {
        self.tableView.backgroundView = [[VTemplateBackgroundView alloc] initWithFrame:self.tableView.bounds];
    }
}

#pragma mark - Actions

- (IBAction)takePicture:(id)sender
{
    VWorkspaceFlowController *workspaceFlowController = [self.dependencyManager workspaceFlowControllerWithAddedDependencies:@{ VImageToolControllerInitialImageEditStateKey: @(VImageToolControllerInitialImageEditStateFilter) }];
    workspaceFlowController.delegate = self;
    workspaceFlowController.videoEnabled = NO;
    workspaceFlowController.shouldUseProfileImagePermissionRequest = YES;
    [self presentViewController:workspaceFlowController.flowRootViewController
                       animated:YES
                     completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    self.tagLinePlaceholderLabel.hidden = ([textView.text length] > 0);

    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.tagLinePlaceholderLabel.hidden = ([textView.text length] > 0);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location != NSNotFound)
    {
        [textView resignFirstResponder];
    }

    return YES;
}

#pragma mark - VContentInputAccessoryViewDelegate

- (BOOL)shouldLimitTextEntryForInputAccessoryView:(VContentInputAccessoryView *)inputAccessoryView
{
    return YES;
}

- (BOOL)shouldAddHashTagsForInputAccessoryView:(VContentInputAccessoryView *)inputAccessoryView
{
    return NO;
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
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectImageForEditProfile];
    
    self.profileImageView.image = previewImage;
    self.updatedProfileImage = capturedMediaURL;

    [self.backgroundImageView setBlurredImageWithClearImage:previewImage
                                           placeholderImage:nil
                                                  tintColor:[UIColor colorWithWhite:1.0 alpha:kBlurredWhiteAlpha]];
    self.tableView.backgroundView = self.backgroundImageView;
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (BOOL)shouldShowPublishForWorkspaceFlowController:(VWorkspaceFlowController *)workspaceFlowController
{
    return NO;
}

@end
