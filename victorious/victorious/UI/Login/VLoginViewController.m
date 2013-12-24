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
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.emailTextField.delegate  =   self;
    self.passwordTextField.delegate  =   self;
}

#pragma mark -

- (BOOL)shouldLoginWithUsername:(NSString *)emailAddress password:(NSString *)password
{
    NSError*    theError;

    if (![self validateEmailAddress:&emailAddress error:&theError])
    {
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InvalidCredentials", @"")
                                                               message:theError.localizedDescription
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                     otherButtonTitles:nil];
        [alert show];
        [[self view] endEditing:YES];
        return NO;
    }
    
    if (![self validatePassword:&password error:&theError])
    {
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InvalidCredentials", @"")
                                                               message:theError.localizedDescription
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                     otherButtonTitles:nil];
        [alert show];
        [[self view] endEditing:YES];
        return NO;
    }
    
    return YES;
}

- (void)didLoginWithUser:(VUser*)mainUser
{
    VLog(@"Succesfully logged in as: %@", mainUser);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LoggedInChangedNotification object:nil];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didFailToLogin:(NSError*)error
{
    UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginFail", @"")
                                                           message:error.localizedDescription
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                 otherButtonTitles:nil];
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

- (BOOL)validateEmailAddress:(id *)ioValue error:(NSError * __autoreleasing *)outError
{
    static  NSString *emailRegEx =
    @"(?:[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[A-Za-z0-9](?:[a-"
    @"z0-9-]*[A-Za-z0-9])?\\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[A-Za-z0-9-]*[A-Za-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    
    NSPredicate*  emailTest =   [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    if (!(*ioValue && [emailTest evaluateWithObject:*ioValue]))
    {
        if (outError != NULL)
        {
            NSString *errorString = NSLocalizedString(@"EmailValidation", @"Invalid Email Address");
            NSDictionary*   userInfoDict = @{ NSLocalizedDescriptionKey : errorString };
            *outError   =   [[NSError alloc] initWithDomain:kVLoginViewControllerDomain
                                                   code:VLoginViewControllerBadEmailAddressErrorCode
                                               userInfo:userInfoDict];
        }
        
        return NO;
    }
    
    return YES;
}

- (BOOL)validatePassword:(id *)ioValue error:(NSError * __autoreleasing *)outError
{
    if ((*ioValue == nil) || ([(NSString *)*ioValue length] < 8))
    {
        if (outError != NULL)
        {
            NSString *errorString = NSLocalizedString(@"PasswordValidation", @"Invalid Password");
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
    if ([self shouldLoginWithUsername:self.emailTextField.text password:self.passwordTextField.text])
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
        
        [[[VObjectManager sharedManager] loginToVictoriousWithEmail:self.emailTextField.text
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
            VLog(@"Twitter Access Token: %@", accessToken);
            
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.emailTextField])
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

