//
//  VLoginViewController.m
//  victoriOS
//
//  Created by goWorld on 12/3/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VLoginViewController.h"
@import Accounts;
@import Social;

@implementation VLoginViewController

+ (VLoginViewController *)sharedLoginViewController
{
    static  VLoginViewController*   loginViewController;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        loginViewController = (VLoginViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: @"loginSelect"];
    });
    
    return loginViewController;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self    =   [super initWithCoder:aDecoder];
    if (self)
    {
        _authorized =   NO;
    }
    
    return self;
}

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

- (IBAction)facebookClicked:(id)sender
{
    __block ACAccount*  facebookAccount;
    ACAccountStore* accountStore = [[ACAccountStore alloc] init];
    ACAccountType *facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    // Specify App ID and permissions
    NSDictionary *options = @{
                              ACFacebookAppIdKey: @"012345678912345",
                              };
    
    [accountStore requestAccessToAccountsWithType:facebookAccountType options:options completion:^(BOOL granted, NSError *e)
    {
          if (granted)
          {
              NSArray *accounts = [accountStore accountsWithAccountType:facebookAccountType];
              facebookAccount = [accounts lastObject];

              ACAccountCredential*  fbCredential = [facebookAccount credential];
              NSString* accessToken = [fbCredential oauthToken];
              NSLog(@"Facebook Access Token: %@", accessToken);
          }
          else
          {
              //    [self performSegueWithIdentifier:@"facebook" sender:self];
          }
    }];
}

- (IBAction)twitterClicked:(id)sender
{
    ACAccountStore* account = [[ACAccountStore alloc] init];
    ACAccountType* accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
    {
        if (granted == YES)
        {
            NSArray *accounts = [account accountsWithAccountType:accountType];
            ACAccount *twitterAccount = [accounts lastObject];
                
            ACAccountCredential*  ftwCredential = [twitterAccount credential];
            NSString* accessToken = [ftwCredential oauthToken];
            NSLog(@"Twitter Access Token: %@", accessToken);

//                NSDictionary *message = @{@"status": @”My First Twitter post from iOS6”};
//                
//                NSURL *requestURL = [NSURL
//                                     URLWithString:@"http://api.twitter.com/1/statuses/update.json"];
//                
//                SLRequest *postRequest = [SLRequest
//                                          requestForServiceType:SLServiceTypeTwitter
//                                          requestMethod:SLRequestMethodPOST
//                                          URL:requestURL parameters:message];
//                
//                postRequest.account = twitterAccount;
//                
//                [postRequest performRequestWithHandler:^(NSData *responseData,
//                                                         NSHTTPURLResponse *urlResponse, NSError *error)
//                 {
//                     NSLog(@"Twitter HTTP response: %i", [urlResponse 
//                                                          statusCode]);
//                 }];
//            }
        }
        else
        {
            [self performSegueWithIdentifier:@"twitter" sender:self];
        }
    }];
}

- (IBAction)emailClicked:(id)sender
{
    [self performSegueWithIdentifier:@"email" sender:self];
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end


