//
//  VLoginViewController.m
//  victoriOS
//
//  Created by goWorld on 12/3/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VLoginViewController.h"
#import "VSequenceManager.h"
#import "VObjectManager.h"

@import Accounts;
@import Social;

@interface      VLoginViewController    ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (nonatomic, readwrite, weak) VUser* mainUser;
@end

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

- (BOOL) authorized
{
    return (_mainUser != nil && (NSNull*)_mainUser != [NSNull null]);
}

#pragma mark -

- (BOOL)shouldLoginWithUsername:(NSString *)username password:(NSString *)password
{
    if (!username || (0 == username.length) || !password || (0 == password.length))
    {
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:@"Invalid E-mail or password" message:@"You must enter an email and password." delegate:self cancelButtonTitle:@"Understood" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    return YES;
}

- (void)didLoginWithUser:(VUser*)mainUser
{
    BOOL auth = [VObjectManager sharedManager].authorized;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didFailToLogin:(NSError*)error
{
    UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:@"Login Failed" message:error.localizedDescription delegate:self cancelButtonTitle:@"Understood" otherButtonTitles:nil];
    [alert show];
}

- (void)didCancelLogin
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)requestAccessFailed
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                       [self presentViewController:composeViewController animated:NO completion:^{
                           [composeViewController dismissViewControllerAnimated:NO completion:nil];
                       }];
                   });
}

#pragma mark -

- (IBAction)login:(id)sender
{
    if ([self shouldLoginWithUsername:self.username.text password:self.password.text])
    {
        SuccessBlock success = ^(NSArray* objects) {
            [self didLoginWithUser:[objects firstObject]];
        };
        FailBlock fail = ^(NSError* error) {
            [self didFailToLogin:error];
            VLog(@"Error in victorious Login: %@", error);
        };
        RKManagedObjectRequestOperation* requestOperation =
            [[VObjectManager sharedManager] loginToVictoriousWithEmail:self.username.text
                                                              password:self.password.text
                                                          successBlock:success
                                                             failBlock:fail];
        [requestOperation start];
    }
}


- (IBAction)facebookClicked:(id)sender
{
    ACAccountStore * const accountStore = [ACAccountStore new];
    ACAccountType * const accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    [accountStore requestAccessToAccountsWithType:accountType
                                          options:@{
                                                    ACFacebookAppIdKey: @"1374328719478033",
                                                    ACFacebookPermissionsKey: @[@"email"] // Needed for first login
                                                    }
                                       completion:^(BOOL granted, NSError *error) {
                                           if (!granted)
                                           {
                                               switch (error.code)
                                               {
                                                   case ACErrorAccountNotFound:
                                                   {
                                                       [self requestAccessFailed];
                                                       break;
                                                   }
                                                   default:
                                                   {
                                                       [self didFailToLogin:error];
                                                       break;
                                                   }
                                               }
                                               return;
                                           }
                                           else {
                                               
                                               NSArray *accounts = [accountStore accountsWithAccountType:accountType];
                                               //it will always be the last object with single sign on
                                               ACAccount* facebookAccount = [accounts lastObject];
                                               ACAccountCredential *fbCredential = [facebookAccount credential];
                                               NSString *accessToken = [fbCredential oauthToken];
                                               
                                               SuccessBlock success = ^(NSArray* objects) {
                                                   [self didLoginWithUser:[objects firstObject]];
                                               };
                                               FailBlock failed = ^(NSError* error) {
                                                   [self didFailToLogin:error];
                                                   VLog(@"Error in FB Login: %@", error);
                                               };
                                               
                                               [[[VObjectManager sharedManager]
                                                 loginToFacebookWithToken:accessToken
                                                             SuccessBlock:success
                                                                failBlock:failed] start];
                                           }
                                       }];
}

- (IBAction)twitterClicked:(id)sender
{
    ACAccountStore* account = [[ACAccountStore alloc] init];
    ACAccountType* accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
    {
        if (!granted)
        {
            switch (error.code)
            {
                case ACErrorAccountNotFound:
                {
                    [self requestAccessFailed];
                    break;
                }
                default:
                {
                    [self didFailToLogin:error];
                    break;
                }
            }
            return;
        }
        else {
            SuccessBlock success = ^(NSArray* objects) {
                [self didLoginWithUser:[objects firstObject]];
            };
            FailBlock failed = ^(NSError* error) {
                [self didFailToLogin:error];
                VLog(@"Error in Twitter Login: %@", error);
            };
            
            NSArray *accounts = [account accountsWithAccountType:accountType];
            ACAccount *twitterAccount = [accounts lastObject];
            
            ACAccountCredential*  ftwCredential = [twitterAccount credential];
            NSString* accessToken = [ftwCredential oauthToken];
            NSLog(@"Twitter Access Token: %@", accessToken);
            
            [[[VObjectManager sharedManager]
              loginToTwitterWithToken:accessToken
                         SuccessBlock:success
                            failBlock:failed] start];
        }
    }];
}

- (IBAction)cancelClicked:(id)sender
{
    [self didCancelLogin];
}

#pragma mark -

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

-(IBAction)unwindToLoginVC:(UIStoryboardSegue *)segue
{
    
}

@end


