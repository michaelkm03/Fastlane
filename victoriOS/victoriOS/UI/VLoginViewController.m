//
//  VLoginViewController.m
//  victoriOS
//
//  Created by goWorld on 12/3/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VLoginViewController.h"
#import "VSequenceManager.h"
@import Accounts;
@import Social;

@interface      VLoginViewController    ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
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

- (void)didLogin
{
    self.authorized =   YES;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didFailToLogIn
{
    UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Unable to log in." delegate:self cancelButtonTitle:@"Understood" otherButtonTitles:nil];
    [alert show];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didCancelLogin
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -

- (IBAction)login:(id)sender
{
    if ([self shouldLoginWithUsername:self.username.text password:self.password.text])
    {
        RKManagedObjectRequestOperation* requestOperation = [[RKObjectManager sharedManager]
                                                             appropriateObjectRequestOperationWithObject:nil
                                                             method:RKRequestMethodPOST
                                                             path:@"/api/login"
                                                             parameters:@{@"email": self.username.text,
                                                                          @"password": self.password.text}];
        
        [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
                                                          RKMappingResult *mappingResult)
         {
             RKLogInfo(@"Login with User: %@", mappingResult.array);
             [self didLogin];
         } failure:^(RKObjectRequestOperation *operation, NSError *error)
         {
             RKLogError(@"Operation failed with error: %@", error);
             [self didFailToLogIn];
         }];
        
        [requestOperation start];
    }
}


- (IBAction)facebookClicked:(id)sender
{
    ACAccountStore* accountStore = [[ACAccountStore alloc] init];
    ACAccountType *facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    // Specify App ID and permissions
    NSDictionary *options = @{
                              ACFacebookAppIdKey: @"012345678912345",
                              };
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];

    [accountStore requestAccessToAccountsWithType:facebookAccountType options:options completion:^(BOOL granted, NSError *e)
    {
          if (granted)
          {
              NSArray *accounts = [accountStore accountsWithAccountType:facebookAccountType];
              ACAccount*    facebookAccount = [accounts lastObject];

              ACAccountCredential*  fbCredential = [facebookAccount credential];
              NSString* accessToken = [fbCredential oauthToken];
              NSLog(@"Facebook Access Token: %@", accessToken);

              RKManagedObjectRequestOperation* requestOperation;
              if(accessToken)
              {
                  requestOperation = [[RKObjectManager sharedManager]
                                      appropriateObjectRequestOperationWithObject:nil
                                      method:RKRequestMethodPOST
                                      path:@"/api/login/facebook"
                                      parameters:@{@"facebook_access_token": accessToken}];
              }
              
              [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
                                                                RKMappingResult *mappingResult)
               {
                   RKLogInfo(@"Login with User: %@", mappingResult.array);
                   [self didLogin];
                  [VSequenceManager loadSequenceCategories];
               } failure:^(RKObjectRequestOperation *operation, NSError *error)
               {
                   RKLogError(@"Operation failed with error: %@", error);
                   [self didFailToLogIn];
               }];
              
              [requestOperation start];
          }
    }];
}

- (IBAction)twitterClicked:(id)sender
{
//    ACAccountStore* account = [[ACAccountStore alloc] init];
//    ACAccountType* accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
//    
//    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
//    {
//        if (granted == YES)
//        {
//            NSArray *accounts = [account accountsWithAccountType:accountType];
//            ACAccount *twitterAccount = [accounts lastObject];
//                
//            ACAccountCredential*  ftwCredential = [twitterAccount credential];
//            NSString* accessToken = [ftwCredential oauthToken];
//            NSLog(@"Twitter Access Token: %@", accessToken);
//        }
//        else
//        {
////            [self performSegueWithIdentifier:@"twitter" sender:self];
//        }
//        
//        [self didLogin];
//    }];
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


