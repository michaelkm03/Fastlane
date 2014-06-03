//
//  VProfileCreateViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileCreateViewController.h"
#import "VCameraViewController.h"
#import "VFollowFriendsViewController.h"
#import "VUser.h"
#import "TTTAttributedLabel.h"
#import "VThemeManager.h"
#import "VObjectManager+Login.h"
#import "VConstants.h"
#import "UIImageView+Blurring.h"
#import "UIImage+ImageEffects.h"

@import CoreLocation;
@import AddressBookUI;

@interface VProfileCreateViewController () <UITextFieldDelegate, UITextViewDelegate, TTTAttributedLabelDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet UITextField*           usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField*           locationTextField;
@property (nonatomic, weak) IBOutlet UITextView*            taglineTextView;
@property (nonatomic, weak) IBOutlet UILabel*               tagLinePlaceholderLabel;

@property (nonatomic, weak) IBOutlet UIImageView*           profileImageView;

@property (nonatomic, strong) CLLocationManager*            locationManager;
@property (nonatomic, strong) CLGeocoder*                   geoCoder;

@property (nonatomic, weak) IBOutlet    UISwitch*           agreeSwitch;
@property (nonatomic, weak) IBOutlet    TTTAttributedLabel* agreementText;
@property (nonatomic, weak) IBOutlet    UIButton*           doneButton;

@property (nonatomic, strong)   NSURL*                      updatedProfileImage;

@property (nonatomic, strong)   UIBarButtonItem*            countDownLabel;

@end

@implementation VProfileCreateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (IS_IPHONE_5)
        self.view.layer.contents = (id)[[[VThemeManager sharedThemeManager] themedImageForKey:kVMenuBackgroundImage5] applyBlurWithRadius:25 tintColor:[UIColor colorWithWhite:1.0 alpha:0.7] saturationDeltaFactor:1.8 maskImage:nil].CGImage;
    else
        self.view.layer.contents = (id)[[[VThemeManager sharedThemeManager] themedImageForKey:kVMenuBackgroundImage] applyBlurWithRadius:25 tintColor:[UIColor colorWithWhite:1.0 alpha:0.7] saturationDeltaFactor:1.8 maskImage:nil].CGImage;
    
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.layer.cornerRadius = CGRectGetHeight(self.profileImageView.bounds)/2;
    self.profileImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.profileImageView.layer.shouldRasterize = YES;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.userInteractionEnabled = YES;
    [self.profileImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takePicture:)]];

    self.usernameTextField.delegate = self;
    self.usernameTextField.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.usernameTextField.text = self.profile.name;
    self.usernameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.usernameTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    
    self.locationTextField.delegate = self;
    self.locationTextField.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    if (self.profile.location)
        self.locationTextField.text = self.profile.location;
    else
        self.locationTextField.text = @"";
    self.locationTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.locationTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    
    self.tagLinePlaceholderLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.tagLinePlaceholderLabel.textColor = [UIColor colorWithWhite:0.14 alpha:1.0];

    self.taglineTextView.delegate = self;
    self.taglineTextView.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.taglineTextView.text = self.profile.tagline;
    if ([self respondsToSelector:@selector(textViewDidChange:)])
        [self textViewDidChange:self.taglineTextView];
    [self createInputAccessoryView];
    
    self.agreementText.delegate = self;
    self.agreementText.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel2Font];
    [self.agreementText setText:[[VThemeManager sharedThemeManager] themedStringForKey:kVAgreementText]];
    NSRange linkRange = [self.agreementText.text rangeOfString:[[VThemeManager sharedThemeManager] themedStringForKey:kVAgreementLinkText]];
    if (linkRange.length > 0)
    {
        NSURL *url = [NSURL URLWithString:[[VThemeManager sharedThemeManager] themedStringForKey:kVAgreementLink]];
        [self.agreementText addLinkToURL:url withRange:linkRange];
    }
    
    self.doneButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton1Font];
    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.doneButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    
    self.agreeSwitch.onTintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController setNavigationBarHidden:NO animated:NO];

    [self.usernameTextField becomeFirstResponder];
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.locationManager  stopMonitoringSignificantLocationChanges];
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
    return YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.usernameTextField])
        [self.locationTextField becomeFirstResponder];
    else if ([textField isEqual:self.locationTextField])
        [self.taglineTextView becomeFirstResponder];
    
    return NO;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
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
    
    BOOL    isDeleteKey = ([text isEqualToString:@""]);
    if ((textView.text.length >= VConstantsMessageLength) && (!isDeleteKey))
        return NO;
    
    return YES;
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - CCLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager  stopMonitoringSignificantLocationChanges];

    CLLocation *location = [locations lastObject];

    self.geoCoder = [[CLGeocoder alloc] init];
    [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
    {
        CLPlacemark*            mapLocation = [placemarks firstObject];
        NSMutableDictionary*    locationDictionary = [NSMutableDictionary dictionaryWithCapacity:3];

        if (mapLocation.locality)
            [locationDictionary setObject:mapLocation.locality forKey:(__bridge NSString *)kABPersonAddressCityKey];

        if (mapLocation.administrativeArea)
            [locationDictionary setObject:mapLocation.administrativeArea forKey:(__bridge NSString *)kABPersonAddressStateKey];

        [locationDictionary setObject:[[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleCountryCode] forKey:(__bridge NSString *)kABPersonAddressCountryCodeKey];
        self.locationTextField.text = ABCreateStringWithAddressDictionary(locationDictionary, NO);
    }];
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    if ([self shouldCreateProfile])
    {
        [[VObjectManager sharedManager] updateVictoriousWithEmail:nil
                                                         password:nil
                                                             name:self.usernameTextField.text
                                                  profileImageURL:self.updatedProfileImage
                                                         location:self.locationTextField.text
                                                          tagline:self.taglineTextView.text
                                                     successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
         {
             VLog(@"Succeeded with objects: %@", resultObjects);
#warning Temporary to prevent someone from going into invite friends. We will re-open this we finihs App Store release, and we finish the implementation for this
//             [self performSegueWithIdentifier:@"toInviteFriends" sender:self];
             [self dismissViewControllerAnimated:YES completion:nil];
         }
                                                        failBlock:^(NSOperation* operation, NSError* error)
         {
             VLog(@"Failed with error: %@", error);
         }];
    }
}

- (BOOL)shouldCreateProfile
{
    BOOL    isValid =   ((self.usernameTextField.text.length > 0) &&
                         (self.locationTextField.text.length > 0) &&
                         (self.taglineTextView.text.length > 0) &&
//                         (self.updatedProfileImage) &&
                         ([self.agreeSwitch isOn]));
    
    if (isValid)
        return YES;
    
    UIAlertView*    alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ProfileIncomplete", @"")
                                                       message:NSLocalizedString(@"ProfileRequired", @"")
                                                      delegate:nil
                                             cancelButtonTitle:nil
                                             otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
    [alert show];
    
    return NO;
}

- (IBAction)takePicture:(id)sender
{
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    VCameraViewController *cameraViewController = [VCameraViewController cameraViewControllerLimitedToPhotos];
    cameraViewController.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        if (finished && capturedMediaURL)
        {
            self.profileImageView.image = previewImage;
            self.updatedProfileImage = capturedMediaURL;
        }
    };
    [navigationController pushViewController:cameraViewController animated:NO];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toInviteFriends"])
    {
//        VInviteFriendsViewController*   inviteViewController = (VInviteFriendsViewController *)segue.destinationViewController;
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
    UIToolbar*  toolbar =   [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    
    UIBarButtonItem*    flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                      target:nil
                                                                                      action:nil];
    
    self.countDownLabel = [[UIBarButtonItem alloc] initWithTitle:[NSNumberFormatter localizedStringFromNumber:@(VConstantsMessageLength) numberStyle:NSNumberFormatterDecimalStyle]
                                                           style:UIBarButtonItemStyleBordered
                                                          target:nil
                                                          action:nil];
    
    toolbar.items = @[flexibleSpace, self.countDownLabel];
    self.taglineTextView.inputAccessoryView = toolbar;
}

@end
