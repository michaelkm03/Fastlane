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
#import "VUserManager.h"
#import <MBProgressHUD/MBProgressHUD.h>

#import "VContentInputAccessoryView.h"

#import "VObjectManager+Login.h"
#import "VObjectManager+Websites.h"

#import "VConstants.h"
#import "UIImageView+WebCache.h"

#import "UIAlertView+VBlocks.h"
#import "VAutomation.h"
#import "VButton.h"

#import "VLocationManager.h"

@import CoreLocation;
@import AddressBookUI;

@interface VProfileCreateViewController () <UITextFieldDelegate, TTTAttributedLabelDelegate, VWorkspaceFlowControllerDelegate, VLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField *locationTextField;
@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;
@property (nonatomic, weak) IBOutlet VButton *doneButton;

@property (nonatomic, strong) VLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geoCoder;

@property (nonatomic, strong) UIBarButtonItem *countDownLabel;
@property (nonatomic, strong) UIBarButtonItem *usernameCountDownLabel;

@property (nonatomic, assign) BOOL addedAccessoryView;
@property (nonatomic, assign) CGFloat previousKeyboardHeight;

@end

@implementation VProfileCreateViewController

@synthesize registrationStepDelegate; //< VRegistrationStep

@synthesize authorizedAction; //< VAuthorizationProvider

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
    
    self.doneButton.titleLabel.font = [self.dependencyManager fontForKey:@"font.header"];
    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.doneButton.primaryColor = [self.dependencyManager colorForKey:@"color.link"];
    self.doneButton.style = VButtonStylePrimary;

    self.profileImageView.layer.borderWidth = 2.0;
    self.profileImageView.layer.borderColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey].CGColor;
    self.profileImageView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.profileImageView.backgroundColor = [UIColor whiteColor];
    
    // Accessibility IDs
    self.doneButton.accessibilityIdentifier = VAutomationIdentifierProfileDone;
    self.usernameTextField.accessibilityIdentifier = VAutomationIdentifierProfileUsernameField;
    self.locationTextField.accessibilityIdentifier = VAutomationIdentifierProfileLocationField;
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
    return UIInterfaceOrientationMaskPortrait;
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

    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    if (countryCode != nil)
    {
        [locationDictionary setObject:countryCode forKey:(__bridge NSString *)kABPersonAddressCountryCodeKey];
    }
    
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
        [self done:nil];
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
                self.authorizedAction(YES);
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
                                                 cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                 otherButtonTitles:nil];
    [alert show];
    
    [MBProgressHUD hideHUDForView:self.view
                         animated:YES];
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    if ([self shouldCreateProfile])
    {
        if (!self.registrationModel.username.length &&
            !self.registrationModel.profileImageURL &&
            !self.registrationModel.locationText.length)
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
                                                      tagline:nil
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
    
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^(void)
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidConfirmExitCreateProfile];
        [self exitWithSuccess:NO];
    }];
    
    [alert show];
}

- (BOOL)shouldCreateProfile
{
    BOOL    isValid =   (self.usernameTextField.text.length > 0);
    
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
    
    NSDictionary *params = @{ VTrackingKeyErrorMessage : errorMsg ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCreateProfileValidationDidFail parameters:params];
    
    // Show Error Message
    UIAlertView    *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ProfileIncomplete", @"")
                                                       message:errorMsg
                                                      delegate:nil
                                             cancelButtonTitle:nil
                                             otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
    [alert show];

    [MBProgressHUD hideHUDForView:self.view
                         animated:YES];
    
    return NO;
}

#pragma mark - Support

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

- (void)updateWithRegistrationModel
{
    self.usernameTextField.text = self.registrationModel.username;
    self.locationTextField.text = self.registrationModel.locationText;
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
