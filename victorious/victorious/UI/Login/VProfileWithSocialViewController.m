//
//  VLoginWithSocialViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileWithSocialViewController.h"
#import "VInviteWithSocialViewController.h"
#import "VUser.h"

@interface VProfileWithSocialViewController ()
@property (nonatomic, weak) IBOutlet    UITextField*    nameTextField;
@property (nonatomic, weak) IBOutlet    UISwitch*       agreeSwitch;
@end

@implementation VProfileWithSocialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.nameTextField.delegate = self;
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
