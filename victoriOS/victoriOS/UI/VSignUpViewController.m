//
//  VEmailLoginViewController.m
//  victoriOS
//
//  Created by Gary Philipp on 12/5/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VSignUpViewController.h"

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

- (void)didFailToSignUp
{
    UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:@"Sign Up Failed" message:@"Unable to sign up." delegate:self cancelButtonTitle:@"Understood" otherButtonTitles:nil];
    [alert show];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -

- (IBAction)signup:(id)sender
{
//    RKManagedObjectRequestOperation* requestOperation = [[RKObjectManager sharedManager]
//                                                         appropriateObjectRequestOperationWithObject:nil
//                                                         method:RKRequestMethodPOST
//                                                         path:@"/api/account/create"
//                                                         parameters:@{@"email" : email,
//                                                                      @"password" : password,
//                                                                      @"name" : name}];
//    
//    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
//                                                      RKMappingResult *mappingResult)
//     {
//         RKLogInfo(@"Login in with user: %@", mappingResult.array);
//         RKManagedObjectRequestOperation* requestOperation = [[RKObjectManager sharedManager]
//                                                              appropriateObjectRequestOperationWithObject:nil
//                                                              method:RKRequestMethodPOST
//                                                              path:@"/api/login"
//                                                              parameters:@{@"email": email,
//                                                                           @"password": password}];
//         
//         [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
//                                                           RKMappingResult *mappingResult)
//          {
//              RKLogInfo(@"Login with User: %@", mappingResult.array);
//          } failure:^(RKObjectRequestOperation *operation, NSError *error)
//          {
//              RKLogError(@"Operation failed with error: %@", error);
//          }];
//         
//         [requestOperation start];
//     } failure:^(RKObjectRequestOperation *operation, NSError *error)
//     {
//         RKLogError(@"Operation failed with error: %@", error);
//     }];
//    
//    [requestOperation start];
}

@end
