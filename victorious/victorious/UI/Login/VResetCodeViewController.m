//
//  VResetCodeViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VResetCodeViewController.h"
#import "VObjectManager+Login.h"

@interface VResetCodeViewController ()

@end

@implementation VResetCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)resendEmail:(id)sender
{
    
}

- (IBAction)checkCode:(id)sender
{
    NSString*   userToken;

    [[VObjectManager sharedManager] resetPasswordWithUserToken:userToken
                                                   deviceToken:self.deviceToken
                                                  successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
         
    }
                                                     failBlock:^(NSOperation* operation, NSError* error)
    {
        UIAlertView*    alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CannotVerify", @"")
                                                           message:NSLocalizedString(@"IncorrectCode", @"")
                                                          delegate:nil
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
        [alert show];
    }];
}

@end
