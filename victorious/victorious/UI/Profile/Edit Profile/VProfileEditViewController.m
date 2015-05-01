//
//  VProfileEditViewController.m
//  victorious
//
//  Created by Kevin Choi on 1/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileEditViewController.h"
#import "VSettingManager.h"
#import "VUser.h"
#import "MBProgressHUD.h"

#import "VObjectManager+Login.h"
#import "VThemeManager.h"

#import "VUserProfileViewController.h"

@interface VProfileEditViewController ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, assign) BOOL isProfileBeingSaved;

@end

@implementation VProfileEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.nameLabel setTextColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!self.profile)
    {
        [self.navigationController.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse
                                                                    usingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             if ([obj isKindOfClass:[VUserProfileViewController class]])
             {
                 VUserProfileViewController *userProfile = obj;
                 self.profile = userProfile.user;
                 *stop = YES;
             }
         }];
    }
    
    [super viewWillAppear:animated];
    
    self.nameLabel.text = self.profile.name;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:VTrackingEventProfileEditDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VTrackingManager sharedInstance] endEvent:VTrackingEventProfileEditDidAppear];
    
    if (![self.navigationController.viewControllers containsObject:self] && !self.isProfileBeingSaved)
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidExitEditProfile];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - Actions

- (IBAction)done:(UIBarButtonItem *)sender
{
    self.isProfileBeingSaved = YES;
    
    [[self view] endEditing:YES];
    
    if (![self validateInputs])
    {
        return;
    }
    sender.enabled = NO;

    MBProgressHUD  *progressHUD =   [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHUD.labelText = NSLocalizedString(@"JustAMoment", @"");
    progressHUD.detailsLabelText = NSLocalizedString(@"ProfileSave", @"");

    [[VObjectManager sharedManager] updateVictoriousWithEmail:nil
                                                     password:nil
                                                         name:self.usernameTextField.text
                                              profileImageURL:self.updatedProfileImage
                                                     location:self.locationTextField.text
                                                      tagline:self.taglineTextView.text
                                                 successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventProfileDidUpdated];
        
        [progressHUD hide:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
                                                    failBlock:^(NSOperation *operation, NSError *error)
    {   
        [progressHUD hide:YES];
        sender.enabled = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"ProfileSaveFail", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

/**
 Validates input fields and displays an alert
 to the user if their input is not valid.
 
 @return YES if all inputs were valid, NO
         otherwise
 */
- (BOOL)validateInputs
{
    if (self.usernameTextField.text.length)
    {
        return YES;
    }
    
    // Identify Which Form Field is Missing
    NSMutableString *errorMsg = [[NSMutableString alloc] initWithString:NSLocalizedString(@"ProfileRequired", @"")];
    
    if (!self.usernameTextField.text.length)
    {
        [errorMsg appendFormat:@"\n%@", NSLocalizedString(@"ProfileRequiredName", @"")];
    }
        
    NSDictionary *params = @{ VTrackingKeyErrorMessage : errorMsg ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventEditProfileValidationDidFail parameters:params];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ProfileIncomplete", @"")
                                                    message:errorMsg
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
    [alert show];
    
    return NO;
}

- (IBAction)goBack:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidExitEditProfile];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
