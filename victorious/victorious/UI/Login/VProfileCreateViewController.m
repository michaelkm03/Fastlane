//
//  VProfileCreateViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileCreateViewController.h"
#import "VCameraViewController.h"
#import "VInviteFriendsViewController.h"
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
@property (nonatomic, weak) IBOutlet UIButton*              cameraButton;

@property (nonatomic, strong) CLLocationManager*            locationManager;
@property (nonatomic, strong) CLGeocoder*                   geoCoder;

@property (nonatomic, weak) IBOutlet    UISwitch*           agreeSwitch;
@property (nonatomic, weak) IBOutlet    TTTAttributedLabel* agreementText;
@property (nonatomic, weak) IBOutlet    UIButton*           doneButton;

@property (nonatomic, strong)   NSURL*                      updatedProfileImage;

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
    self.profileImageView.image = [[UIImage imageNamed:@"profileGenericUser"] applyBlurWithRadius:0.0 tintColor:[UIColor colorWithWhite:1.0 alpha:0.7] saturationDeltaFactor:1.8 maskImage:nil];

    self.cameraButton.layer.masksToBounds = YES;
    self.cameraButton.layer.cornerRadius = CGRectGetHeight(self.cameraButton.bounds)/2;
    self.cameraButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.cameraButton.layer.shouldRasterize = YES;
    self.cameraButton.clipsToBounds = YES;
    
    self.usernameTextField.delegate = self;
    self.usernameTextField.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.usernameTextField.text = self.profile.name;
    
    self.locationTextField.delegate = self;
    self.locationTextField.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.locationTextField.text = self.profile.location;
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    
    self.taglineTextView.delegate = self;
    self.taglineTextView.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.taglineTextView.text = self.profile.tagline;
    if ([self respondsToSelector:@selector(textViewDidChange:)])
        [self textViewDidChange:self.taglineTextView];
    
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

    [self.usernameTextField becomeFirstResponder];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
//    UIImage*    cancelButtonImage = [[UIImage imageNamed:@"cameraButtonClose"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:cancelButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(closeButtonClicked:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.tagLinePlaceholderLabel.hidden = ([textView.text length] > 0);
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

- (IBAction)next:(id)sender
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
     }
                                                    failBlock:^(NSOperation* operation, NSError* error)
     {
         VLog(@"Failed with error: %@", error);
     }];
    
    [self performSegueWithIdentifier:@"toInviteFriends" sender:self];
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
    VInviteFriendsViewController*   inviteViewController = (VInviteFriendsViewController *)segue.destinationViewController;
    inviteViewController.profile = self.profile;
}

#pragma mark - Support

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

@end
