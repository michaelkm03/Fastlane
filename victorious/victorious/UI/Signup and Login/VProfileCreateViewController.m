//
//  VProfileCreateViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileCreateViewController.h"
#import "VWorkspaceFlowController.h"
#import "VImageToolController.h"

#import "VUser.h"
#import "TTTAttributedLabel.h"
#import "VDependencyManager.h"
#import "VSettingManager.h"
#import "VUserManager.h"
#import <MBProgressHUD/MBProgressHUD.h>

#import "VContentInputAccessoryView.h"

#import "VObjectManager+Login.h"
#import "VObjectManager+Websites.h"

#import "VConstants.h"
#import "UIImageView+WebCache.h"

#import "VTOSViewController.h"

#import "UIAlertView+VBlocks.h"
#import "VAutomation.h"
#import "VButton.h"

#import "VLocationManager.h"

@import CoreLocation;
@import AddressBookUI;

@interface VProfileCreateViewController () <UITextFieldDelegate, UITextViewDelegate, TTTAttributedLabelDelegate, VWorkspaceFlowControllerDelegate, VLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField *locationTextField;
@property (nonatomic, weak) IBOutlet UITextView *taglineTextView;
@property (nonatomic, weak) IBOutlet UILabel *tagLinePlaceholderLabel;

@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;

@property (nonatomic, strong) VLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geoCoder;

@property (nonatomic, weak) IBOutlet UISwitch *agreeSwitch;
@property (nonatomic, weak) IBOutlet TTTAttributedLabel *agreementText;
@property (nonatomic, weak) IBOutlet VButton *doneButton;

@property (nonatomic, strong) UIBarButtonItem *countDownLabel;
@property (nonatomic, strong) UIBarButtonItem *usernameCountDownLabel;

@property (nonatomic, assign) BOOL addedAccessoryView;

@property (nonatomic, assign) CGFloat previousKeyboardHeight;

@end

@implementation VProfileCreateViewController

@synthesize registrationStepDelegate; //< VRegistrationStep

@synthesize authorizedAction; //< VAuthorizationViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (VProfileCreateViewController *)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"login" bundle:nil];
    VProfileCreateViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:kProfileCreateStoryboardID];
    viewController.dependencyManager = dependencyManager;
    return viewController;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateWithRegistrationModel];
    
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.layer.cornerRadius = CGRectGetHeight(self.profileImageView.bounds)/2;
    self.profileImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.profileImageView.layer.shouldRasterize = YES;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.userInteractionEnabled = YES;
    [self.profileImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takePicture:)]];
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString: self.profile.pictureUrl]
                          placeholderImage:self.profileImageView.image];
    
    self.usernameTextField.delegate = self;
    self.usernameTextField.font = [self.dependencyManager fontForKey:@"font.header"];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (![self.profile.name isEqualToString:kNoUserName])
    {
        self.usernameTextField.text = self.profile.name;
    }
#pragma clang diagnostic pop
    self.usernameTextField.tintColor = [self.dependencyManager colorForKey:@"color.link"];
    self.usernameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.usernameTextField.placeholder attributes:@{NSForegroundColorAttributeName :[UIColor colorWithWhite:0.355 alpha:1.000]}];
    
    self.locationTextField.delegate = self;
    self.locationTextField.tintColor = [self.dependencyManager colorForKey:@"color.link"];
    self.locationTextField.font = [self.dependencyManager fontForKey:@"font.header"];
    if (self.profile.location)
    {
        self.locationTextField.text = self.profile.location;
    }
    else
    {
        if ([VLocationManager sharedInstance].lastLocationRetrieved != nil)
        {
            CLPlacemark *placemark = [VLocationManager sharedInstance].locationPlacemark;
            NSDictionary *locationDictionary = [self formatLocationData:placemark];
            
            NSString *city = [locationDictionary valueForKey:@"City"];
            NSString *state = [locationDictionary valueForKey:@"State"];
            if ((city == nil) || (state == nil))
            {
                self.locationTextField.text = @"";
            }
            else
            {
                self.locationTextField.text = [NSString stringWithFormat:@"%@, %@", city, state];
                self.registrationModel.locationText = self.locationTextField.text;
            }
        }
        else
        {
            self.locationTextField.text = @"";
        }
    }
    self.locationTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.locationTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.355 alpha:1.0]}];
    if ([CLLocationManager locationServicesEnabled]
        && [CLLocationManager significantLocationChangeMonitoringAvailable]
        && !self.locationTextField.text.length)
    {
        self.locationManager = [VLocationManager sharedInstance];
        self.locationManager.delegate = self;
        [self.locationManager.locationManager requestWhenInUseAuthorization];
    }
    
    self.tagLinePlaceholderLabel.font = [self.dependencyManager fontForKey:@"font.header"];
    [self.tagLinePlaceholderLabel setTextColor:[UIColor colorWithWhite:0.355 alpha:1.000]];

    self.taglineTextView.tintColor = [self.dependencyManager colorForKey:@"color.link"];
    self.taglineTextView.delegate = self;
    self.taglineTextView.font = [self.dependencyManager fontForKey:@"font.header"];
    if (self.profile.tagline)
    {
        self.taglineTextView.text = self.profile.tagline;
    }
    if ([self respondsToSelector:@selector(textViewDidChange:)])
    {
        [self textViewDidChange:self.taglineTextView];
    }
    
    // Create Accessory Views
    [self createInputAccessoryView];
    
    self.agreementText.delegate = self;
    self.agreementText.font = [self.dependencyManager fontForKey:@"font.label2"];
    [self.agreementText setText:NSLocalizedString(@"ToSAgreement", @"")];
    NSRange linkRange = [self.agreementText.text rangeOfString:NSLocalizedString(@"ToSText", @"")];
    if (linkRange.length > 0)
    {
        self.agreementText.linkAttributes = @{(NSString *)
                                              kCTUnderlineStyleAttributeName : @(kCTUnderlineStyleSingle)};
        NSURL *url = [[VSettingManager sharedManager] urlForKey:kVTermsOfServiceURL];
        [self.agreementText addLinkToURL:url withRange:linkRange];
    }
    
    self.doneButton.titleLabel.font = [self.dependencyManager fontForKey:@"font.header"];
    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.doneButton.primaryColor = [self.dependencyManager colorForKey:@"color.link"];
    self.doneButton.style = VButtonStylePrimary;
    
    self.agreeSwitch.onTintColor = [self.dependencyManager colorForKey:@"color.link"];
    
    // Accessibility IDs
    self.doneButton.accessibilityIdentifier = VAutomationIdentifierProfileDone;
    self.usernameTextField.accessibilityIdentifier = VAutomationIdentifierProfileUsernameField;
    self.locationTextField.accessibilityIdentifier = VAutomationIdentifierProfileLocationField;
    self.taglineTextView.accessibilityIdentifier = VAutomationIdentifierProfileTaglineField;
    self.agreeSwitch.accessibilityIdentifier = VAutomationIdentifierProfileAgeAgreeSwitch;
    self.profileImageView.accessibilityIdentifier = VAutomationIdentifierProfilSelectImage;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;

    // Start location monitoring
    [self.locationManager startLocationChangesMonitoring];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.view endEditing:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.registrationModel.username)
    {
        [self.usernameTextField becomeFirstResponder];
    }
    else if (!self.registrationModel.taglineText)
    {
        [self.taglineTextView becomeFirstResponder];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - Format Location Data

- (NSDictionary *)formatLocationData:(CLPlacemark *)placemark
{
    NSMutableDictionary *locationDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    
    if (placemark.locality)
    {
        [locationDictionary setObject:placemark.locality forKey:(__bridge NSString *)kABPersonAddressCityKey];
    }
    
    if (placemark.administrativeArea)
    {
        [locationDictionary setObject:placemark.administrativeArea forKey:(__bridge NSString *)kABPersonAddressStateKey];
    }
    
    [locationDictionary setObject:[(NSLocale *)[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleCountryCode]
                           forKey:(__bridge NSString *)kABPersonAddressCountryCodeKey];
    
    return [locationDictionary copy];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.usernameTextField])
    {
        [self.locationTextField becomeFirstResponder];
    }
    else if ([textField isEqual:self.locationTextField])
    {
        [self.taglineTextView becomeFirstResponder];
    }
    
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL ans = YES;
    if (textField == self.usernameTextField)
    {
        NSString *resultingString = [textField.text stringByReplacingCharactersInRange:range
                                                                            withString:string];
        if (resultingString.length > VConstantsUsernameMaxLength)
        {
            ans = NO;
        }
    }
    
    return ans;
}

- (void)characterCountdown:(id)sender
{
    self.usernameCountDownLabel.title = [NSNumberFormatter localizedStringFromNumber:@(VConstantsUsernameMaxLength - self.usernameTextField.text.length)
                                                                 numberStyle:NSNumberFormatterDecimalStyle];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    self.registrationModel.taglineText = self.taglineTextView.text;
    self.tagLinePlaceholderLabel.hidden = ([textView.text length] > 0);
    self.countDownLabel.title = [NSNumberFormatter localizedStringFromNumber:@(VConstantsMessageLength - self.taglineTextView.text.length)
                                                                 numberStyle:NSNumberFormatterDecimalStyle];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.tagLinePlaceholderLabel.hidden = ([textView.text length] > 0);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - Notification Handlers

static inline UIViewAnimationOptions animationOptionsWithCurve(UIViewAnimationCurve curve)
{
    if ( curve > UIViewAnimationCurveLinear )
    {
        return UIViewAnimationOptionCurveEaseInOut;
    }
    /*
     Can't find a better way, this little hack converts UIViewAnimationCurve to a UIViewAnimationOptions which is useful
     for matching up the animation with the keyboard
     */
    return curve << 16;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect endKeyboardFrame;
    [userInfo[UIKeyboardFrameEndUserInfoKey] getValue:&endKeyboardFrame];
    
    if ( self.previousKeyboardHeight == 0 )
    {
        self.previousKeyboardHeight = CGRectGetHeight(endKeyboardFrame);
    }
    
    if ( [self.taglineTextView isFirstResponder] )
    {
        CGRect startKeyboardFrame;
        [userInfo[UIKeyboardFrameBeginUserInfoKey] getValue:&startKeyboardFrame];

        CGFloat heightDifference = endKeyboardFrame.size.height - self.previousKeyboardHeight;
        
        if ( heightDifference >= CGRectGetHeight(self.taglineTextView.inputAccessoryView.frame) && CGRectGetMinY(startKeyboardFrame) != CGRectGetHeight(self.view.bounds) )
        {
            //The tagTextView is active and just added it's accessoryView (which happens last) so set ready for animation
            self.addedAccessoryView = YES;
        }
        
        if ( self.addedAccessoryView && ( heightDifference != 0 || CGRectGetMinY(startKeyboardFrame) == CGRectGetHeight(self.view.bounds) ) )
        {
            [self updateContentOffsetForKeyboardNotification:notification];
        }
    }
    else
    {
        //The tagTextView is not active so we'll see the accessoryView re-added before we need to animate again
        self.addedAccessoryView = NO;
    }
    
    self.previousKeyboardHeight = CGRectGetHeight(endKeyboardFrame);
}

- (void)updateContentOffsetForKeyboardNotification:(NSNotification *)notification
{
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    NSDictionary *userInfo = [notification userInfo];
    CGRect endKeyboardFrame;
    
    [userInfo[UIKeyboardFrameEndUserInfoKey] getValue:&endKeyboardFrame];
    
    [userInfo[UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    CGFloat yOffset = MAX( - (CGRectGetMinY(self.taglineTextView.frame) + CGRectGetHeight(self.taglineTextView.bounds) - CGRectGetHeight(self.view.bounds) + CGRectGetHeight(endKeyboardFrame) ), - self.taglineTextView.frame.origin.y );
    animationDuration = animationDuration == 0 ? 0.25f : animationDuration;
    [UIView animateWithDuration:animationDuration
                          delay:0.0f
                        options:animationOptionsWithCurve(animationCurve)
                     animations:^
     {
         //Animate the textview to just above the keyboard or, at worst, pinned to top of screen
         self.view.frame = CGRectOffset(self.view.bounds, 0, yOffset);
     }
                     completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    NSDictionary *userInfo = [notification userInfo];
    
    [userInfo[UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration delay:0
                        options:animationOptionsWithCurve(animationCurve)
                     animations:^
     {
         self.view.frame = self.view.bounds;
     }
                     completion:nil];
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    VTOSViewController *termsOfServiceVC = [[UIStoryboard storyboardWithName:@"settings" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([VTOSViewController class])];
    termsOfServiceVC.title = NSLocalizedString(@"ToSText", @"");
    if ( self.navigationController != nil )
    {
        [self showViewController:termsOfServiceVC sender:nil];
    }
    else
    {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:termsOfServiceVC];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

#pragma mark - VLocationManagerDelegate

- (void)didReceiveLocations:(NSArray *)locations withPlacemark:(CLPlacemark *)placemark withLocationManager:(VLocationManager *)locationManager
{
    NSDictionary *locationDictionary = [self formatLocationData:placemark];
    
    NSString *city = [locationDictionary valueForKey:@"City"];
    NSString *state = [locationDictionary valueForKey:@"State"];
    if ((city == nil) || (state == nil))
    {
        return;
    }
    self.locationTextField.text = [NSString stringWithFormat:@"%@, %@", city, state];
    self.registrationModel.locationText = self.locationTextField.text;
}

#pragma mark - State

- (void)didCreateProfile
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateProfileDidSucceed];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [self exitWithSuccess:YES];
}

- (void)exitWithSuccess:(BOOL)success
{
    BOOL wasPresentedStandalone = self.navigationController == nil;
    if ( wasPresentedStandalone )
    {
        [self dismissViewControllerAnimated:YES completion:^
         {  
            if ( self.authorizedAction != nil && success )
            {
                self.authorizedAction();
            }
        }];
    }
    else if ( self.registrationStepDelegate != nil )
    {
        [self.registrationStepDelegate didFinishRegistrationStepWithSuccess:success];
    }
}

- (void)didFailWithError:(NSError *)error
{
    
    UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ProfileSaveFail", @"")
                                                           message:error.localizedDescription
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                 otherButtonTitles:nil];
    [alert show];
    
    [MBProgressHUD hideHUDForView:self.view
                         animated:YES];
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
#warning Hardcoded for testing only:
    if ( YES )
    {
        self.registrationModel.profileImageURL = [NSURL URLWithString:@""];
        self.registrationModel.locationText = @"LOCATION";
        self.registrationModel.taglineText = @"TAG LING";
        [self performProfileCreationWithRegistrationModel:self.registrationModel];
        return;
    }

    if ([self shouldCreateProfile])
    {
        if (!self.registrationModel.username.length &&
            !self.registrationModel.profileImageURL &&
            !self.registrationModel.locationText.length &&
            !self.registrationModel.taglineText.length)
        {
            [self didCreateProfile];
            return;
        }
        
        [self performProfileCreationWithRegistrationModel:self.registrationModel];
    }
}

- (void)performProfileCreationWithRegistrationModel:(VRegistrationModel *)registrationModel
{
    [[VObjectManager sharedManager] updateVictoriousWithEmail:nil
                                                     password:nil
                                                         name:registrationModel.username
                                              profileImageURL:registrationModel.profileImageURL
                                                     location:registrationModel.locationText
                                                      tagline:registrationModel.taglineText
                                                 successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         [self didCreateProfile];
     }
                                                    failBlock:^(NSOperation *operation, NSError *error)
     {
         [self didFailWithError:error];
     }];
}

- (IBAction)takePicture:(id)sender
{
    VWorkspaceFlowController *workspaceFlowController = [VWorkspaceFlowController workspaceFlowControllerWithoutADependencyMangerWithInjection:@{VImageToolControllerInitialImageEditStateKey:@(VImageToolControllerInitialImageEditStateFilter)}];
    workspaceFlowController.delegate = self;
    workspaceFlowController.videoEnabled = NO;
    [self presentViewController:workspaceFlowController.flowRootViewController
                       animated:YES
                     completion:nil];
}

- (IBAction)exit:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectExitCreateProfile];
    
    // Show Error Message
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ProfileIncomplete", @"")
                                       message:NSLocalizedString(@"ProfileAborted", @"")
                             cancelButtonTitle:NSLocalizedString(@"CancelButton", @"")
                                onCancelButton:nil
                    otherButtonTitlesAndBlocks:nil];
    
    [alert addButtonWithTitle:NSLocalizedString(@"OKButton", @"") block:^{
        
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidConfirmExitCreateProfile];
        
        [self exitWithSuccess:NO];
        
    }];
    
    [alert show];
}

- (BOOL)shouldCreateProfile
{
    const BOOL isProfileImageRequired = [[VSettingManager sharedManager] settingEnabledForKey:VExperimentsRequireProfileImage];
    
    BOOL    isValid =   ((self.usernameTextField.text.length > 0) &&
                         (self.locationTextField.text.length > 0) &&
                         (self.registrationModel.profileImageURL || self.profile.pictureUrl.length || !isProfileImageRequired) &&
                         ([self.agreeSwitch isOn]));
    
    if (isValid)
    {
        return YES;
    }
    
    // Identify Which Form Field is Missing
    NSMutableString *errorMsg = [[NSMutableString alloc] initWithString:NSLocalizedString(@"ProfileRequired", @"")];
    
    if (!self.usernameTextField.text.length > 0)
    {
        [errorMsg appendFormat:@"\n%@", NSLocalizedString(@"ProfileRequiredName", @"")];
    }
    
    if (!self.locationTextField.text.length > 0)
    {
        [errorMsg appendFormat:@"\n%@", NSLocalizedString(@"ProfileRequiredLoc", @"")];
    }
    
    if (!self.registrationModel.profileImageURL && !self.profile.pictureUrl.length && isProfileImageRequired)
    {
        [errorMsg appendFormat:@"\n%@", NSLocalizedString(@"ProfileRequiredPhoto", @"")];
    }

    if (![self.agreeSwitch isOn])
    {
        [errorMsg appendFormat:@"\n%@", NSLocalizedString(@"ProfileRequiredToS", @"")];
    }
    
    NSDictionary *params = @{ VTrackingKeyErrorMessage : errorMsg ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateProfileValidationDidFail parameters:params];
    
    // Show Error Message
    UIAlertView    *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ProfileIncomplete", @"")
                                                       message:errorMsg
                                                      delegate:nil
                                             cancelButtonTitle:nil
                                             otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
    [alert show];

    [MBProgressHUD hideHUDForView:self.view
                         animated:YES];
    
    return NO;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toInviteFriends"])
    {
//        VInviteFriendsViewController   *inviteViewController = (VInviteFriendsViewController *)segue.destinationViewController;
//        inviteViewController.profile = self.profile;
    }
}

#pragma mark - Support

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

- (void)createInputAccessoryView
{
    VContentInputAccessoryView *taglineInputAccessory = [[VContentInputAccessoryView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 50.0f)];
    taglineInputAccessory.textInputView = self.taglineTextView;
    taglineInputAccessory.tintColor = [UIColor colorWithRed:0.85f green:0.86f blue:0.87f alpha:1.0f];
    self.taglineTextView.inputAccessoryView = taglineInputAccessory;
}

- (void)updateWithRegistrationModel
{
    self.usernameTextField.text = self.registrationModel.username;
    self.locationTextField.text = self.registrationModel.locationText;
    self.taglineTextView.text = self.registrationModel.taglineText;
    if (self.registrationModel.selectedImage)
    {
        self.profileImageView.image = self.registrationModel.selectedImage;
    }
}

#pragma mark - Notification Handlers

- (void)textFieldDidChange:(NSNotification *)notification
{
    if (notification.object == self.usernameTextField)
    {
        self.registrationModel.username = self.usernameTextField.text;
    }
    else if (notification.object == self.locationTextField)
    {
        self.registrationModel.locationText = self.locationTextField.text;
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
    self.profileImageView.image = previewImage;
    self.registrationModel.selectedImage = previewImage;
    self.registrationModel.profileImageURL = capturedMediaURL;
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (BOOL)shouldShowPublishForWorkspaceFlowController:(VWorkspaceFlowController *)workspaceFlowController
{
    return NO;
}

@end
