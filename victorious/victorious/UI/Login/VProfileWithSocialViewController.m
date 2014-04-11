//
//  VProfileWithSocialViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileWithSocialViewController.h"
#import "VInviteWithSocialViewController.h"
#import "VUser.h"
#import "TTTAttributedLabel.h"
#import "VThemeManager.h"
#import "VObjectManager+Login.h"

@interface VProfileWithSocialViewController () <TTTAttributedLabelDelegate>
@property (nonatomic, weak) IBOutlet    UITextField*        nameTextField;
@property (nonatomic, weak) IBOutlet    UISwitch*           agreeSwitch;
@property (nonatomic, weak) IBOutlet    TTTAttributedLabel* agreementText;
@end

@implementation VProfileWithSocialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.nameTextField.delegate = self;

    self.agreementText.delegate = self;
    [self.agreementText setText:[[VThemeManager sharedThemeManager] themedStringForKey:kVAgreementText]];
    NSRange linkRange = [self.agreementText.text rangeOfString:[[VThemeManager sharedThemeManager] themedStringForKey:kVAgreementLinkText]];
    if (linkRange.length > 0)
    {
        NSURL *url = [NSURL URLWithString:[[VThemeManager sharedThemeManager] themedStringForKey:kVAgreementLink]];
        [self.agreementText addLinkToURL:url withRange:linkRange];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.nameTextField])
        [self.usernameTextField becomeFirstResponder];
    else if ([textField isEqual:self.usernameTextField])
        [self.locationTextField becomeFirstResponder];
    else if ([textField isEqual:self.locationTextField])
        [self.taglineTextView becomeFirstResponder];
    else
        [self.taglineTextView resignFirstResponder];
    
    return YES;
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Actions

- (IBAction)next:(id)sender
{
    [[VObjectManager sharedManager] updateVictoriousWithEmail:nil
                                                     password:nil
                                                     username:self.usernameTextField.text
                                                 profileImage:nil
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
    
    [self performSegueWithIdentifier:@"toInviteWithSocial" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    VInviteWithSocialViewController*   inviteViewController = (VInviteWithSocialViewController *)segue.destinationViewController;
    inviteViewController.profile = self.profile;
}

@end
