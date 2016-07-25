//
//  VProfileEditViewController.m
//  victorious
//
//  Created by Kevin Choi on 1/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileEditViewController.h"
#import "MBProgressHUD.h"
#import "VDependencyManager.h"
#import "VUserProfileViewController.h"
#import "victorious-Swift.h"

@interface VProfileEditViewController ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, assign) BOOL isProfileBeingSaved;

@end

@implementation VProfileEditViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.nameLabel.text = self.profile.displayName;
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

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    [super setDependencyManager:dependencyManager];
    
    [self.nameLabel setTextColor:[dependencyManager colorForKey:VDependencyManagerContentTextColorKey]];
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
    
    // Optimistically update the profile and don't worry about completion/error checking
    [self updateProfileWithName:self.usernameTextField.text
                profileImageURL:self.updatedProfileImage
                       location:self.locationTextField.text
                        tagline:self.taglineTextView.text];
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventProfileDidUpdated];
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 Validates input fields and displays an alert
 to the user if their input is not valid.
 
 @return YES if all inputs were valid, NO
         otherwise
 */
- (BOOL)validateInputs
{
    if (self.usernameTextField.text.length == 0)
    {
        NSMutableString *errorMsg = [[NSMutableString alloc] initWithString:NSLocalizedString(@"ProfileRequired", @"")];
        [errorMsg appendFormat:@"\n%@", NSLocalizedString(@"ProfileRequiredName", @"")];
        NSDictionary *params = @{ VTrackingKeyErrorMessage : errorMsg ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventEditProfileValidationDidFail parameters:params];
        [self showAlertControllerWithTitle:NSLocalizedString(@"ProfileIncomplete", @"")
                                   message:errorMsg];
        return NO;
    }
    
    // Test only spaces
    NSString *stringByRemovingSpaces = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (stringByRemovingSpaces.length == 0)
    {
        [self showAlertControllerWithTitle:NSLocalizedString(@"ProfileIncomplete", nil)
                                   message:NSLocalizedString(@"ProfileNameSpaces", nil)];
        return NO;
    }

    return YES;
}

- (void)showAlertControllerWithTitle:(NSString *)title
                             message:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action)
                                   {
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                   }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
    
}

- (IBAction)goBack:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidExitEditProfile];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
