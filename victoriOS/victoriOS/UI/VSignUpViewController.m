//
//  VEmailLoginViewController.m
//  victoriOS
//
//  Created by Gary Philipp on 12/5/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VSignUpViewController.h"
#import "VObjectManager.h"
#import "VUser.h"

@implementation VSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (BOOL)shouldSignUpWithUsername:(NSString *)username password:(NSString *)password
{
    if (!username || (0 == username.length) || !password || (0 == password.length))
    {
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:@"Invalid E-mail or password" message:@"You must enter an email and password." delegate:self cancelButtonTitle:@"Understood" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    return YES;
}

- (void)didSignUp
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didFailToSignUp:(NSString*)message
{
    UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:@"Account creation failed!" message:message delegate:self cancelButtonTitle:@"Understood" otherButtonTitles:nil];
    [alert show];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -

- (IBAction)signup:(id)sender
{
//    SuccessBlock success = ^(NSArray* objects)
//    {
//        if ([[objects firstObject] isKindOfClass:[VUser class]])
//        {
//            VLog(@"Invalid user object returned in api/account/create");
//            [self didFailToSignUp:@"Sorry, an error has occured.  Please try again!"];
//            return;
//        }
//    };
//    
//    FailBlock fail = ^(NSError* error)
//    {
//        [self didFailToSignUp:[error localizedDescription]];
//    };
//    
//    [[[VObjectManager sharedManager] createToVictoriousWithEmail:self.email.text
//                                                       password:self.password.text
//                                                   successBlock:success
//                                                      failBlock:fail] start];
}

@end
