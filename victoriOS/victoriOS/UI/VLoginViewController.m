//
//  VLoginViewController.m
//  victoriOS
//
//  Created by goWorld on 12/3/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VLoginViewController.h"

#import "VObjectManager+Login.h"

@import Accounts;
@import Social;

NSString*   const   kVLoginViewControllerDomain =   @"VLoginViewControllerDomain";

@interface      VLoginViewController    ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
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
    
	self.usernameTextField.delegate  =   self;
    self.passwordTextField.delegate  =   self;
}

#pragma mark -

- (BOOL)shouldLoginWithUsername:(NSString *)username password:(NSString *)password
{
    NSError*    theError;

    if (![self validateUsername:&username error:&theError] || ![self validatePassword:&password error:&theError])
    {
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:@"Invalid E-mail or password" message:@"You must enter an email and password." delegate:self cancelButtonTitle:@"Understood" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    return YES;
}

- (void)didLoginWithUser:(VUser*)mainUser
{
    VLog(@"Succesfully logged in as: %@", mainUser);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LoggedInNotification object:nil];
    
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

- (void)requestAccessDidFail
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                       [self presentViewController:composeViewController animated:NO completion:^{
                           [composeViewController dismissViewControllerAnimated:NO completion:nil];
                       }];
                   });
}

-(BOOL)validateUsername:(id *)ioValue error:(NSError * __autoreleasing *)outError
{
    // The name must not be nil, and must be at least two characters long.
    if ((*ioValue == nil) || ([(NSString *)*ioValue length] < 8))
    {
        if (outError != NULL)
        {
            NSString *errorString = NSLocalizedString(
                                                      @"A Person's name must be at least two characters long",
                                                      @"validation: Person, too short name error");
            NSDictionary*   userInfoDict = @{ NSLocalizedDescriptionKey : errorString };
            *outError   =   [[NSError alloc] initWithDomain:kVLoginViewControllerDomain
                                                   code:VLoginViewControllerBadUsernameErrorCode
                                               userInfo:userInfoDict];
        }
        
        return NO;
    }
    
    return YES;
}

-(BOOL)validatePassword:(id *)ioValue error:(NSError * __autoreleasing *)outError
{
    // The name must not be nil, and must be at least two characters long.
    if ((*ioValue == nil) || ([(NSString *)*ioValue length] < 8))
    {
        if (outError != NULL)
        {
            NSString *errorString = NSLocalizedString(
                                                      @"A Person's name must be at least two characters long",
                                                      @"validation: Person, too short name error");
            NSDictionary*   userInfoDict = @{ NSLocalizedDescriptionKey : errorString };
            *outError   =   [[NSError alloc] initWithDomain:kVLoginViewControllerDomain
                                                       code:VLoginViewControllerBadPasswordErrorCode
                                                   userInfo:userInfoDict];
        }
        
        return NO;
    }
    
    return YES;
}

#pragma mark -

- (IBAction)login:(id)sender
{
    if ([self shouldLoginWithUsername:self.usernameTextField.text password:self.passwordTextField.text])
    {
        SuccessBlock success = ^(NSArray* objects)
        {
            [self didLoginWithUser:[objects firstObject]];
        };
        FailBlock fail = ^(NSError* error)
        {
            [self didFailToLogin:error];
            VLog(@"Error in victorious Login: %@", error);
        };
        
        [[[VObjectManager sharedManager] loginToVictoriousWithEmail:self.usernameTextField.text
                                                           password:self.passwordTextField.text
                                                       successBlock:success
                                                          failBlock:fail] start];
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
                                       completion:^(BOOL granted, NSError *error)
    {
                                           if (!granted)
                                           {
                                               switch (error.code)
                                               {
                                                   case ACErrorAccountNotFound:
                                                   {
                                                       [self requestAccessDidFail];
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
                                           else
                                           {
                                               NSArray *accounts = [accountStore accountsWithAccountType:accountType];
                                               //it will always be the last object with single sign on
                                               ACAccount* facebookAccount = [accounts lastObject];
                                               ACAccountCredential *fbCredential = [facebookAccount credential];
                                               NSString *accessToken = [fbCredential oauthToken];
                                               
                                               SuccessBlock success = ^(NSArray* objects)
                                               {
                                                   [self didLoginWithUser:[objects firstObject]];
                                               };
                                               FailBlock failed = ^(NSError* error)
                                               {
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
                    [self requestAccessDidFail];
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
        else
        {
            SuccessBlock success = ^(NSArray* objects)
            {
                [self didLoginWithUser:[objects firstObject]];
            };
            FailBlock failed = ^(NSError* error)
            {
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
        //  Scroll textfield into view
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.usernameTextField])
        [self.passwordTextField becomeFirstResponder];
    else
        [self login:self];
    
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

@end


