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
    [self.agreementText setText:@"I'm at least 13 years old and agree to Terms of Service"];
    NSRange linkRange = [self.agreementText.text rangeOfString:@"Terms of Service"];
    if (linkRange.length > 0)
    {
        NSURL *url = [NSURL URLWithString:@"http://en.wikipedia.org/wiki/"];
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
    [self performSegueWithIdentifier:@"toInviteWithSocial" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    VInviteWithSocialViewController*   inviteViewController = (VInviteWithSocialViewController *)segue.destinationViewController;
    inviteViewController.profile = self.profile;
}

@end
