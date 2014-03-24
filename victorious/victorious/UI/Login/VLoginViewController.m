//
//  VLoginViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLoginViewController.h"
#import "VConstants.h"
#import "VThemeManager.h"
#import "VProfileWithSocialViewController.h"
#import "VObjectManager+Login.h"
#import "VUser.h"
#import "TWAPIManager.h"

@import Accounts;
@import Social;

@interface VLoginViewController ()
@property (nonatomic, weak) IBOutlet    UIView*             buttonContainer;
@property (nonatomic, weak) IBOutlet    UIButton*           facebookButton;
@property (nonatomic, weak) IBOutlet    UIButton*           twitterButton;
@property (nonatomic, weak) IBOutlet    UIButton*           emailButton;

@property (nonatomic, strong)           UIDynamicAnimator*  animator;
@property (nonatomic, assign)           VLoginType          loginType;
@property (nonatomic, strong)           VUser*              profile;

@property (nonatomic, strong) TWAPIManager *twitterApiManager;
@end

@implementation VLoginViewController

+ (VLoginViewController *)loginViewController
{
    UIStoryboard*   storyboard  =   [UIStoryboard storyboardWithName:@"login" bundle:nil];
    
    return [storyboard instantiateInitialViewController];
}

- (void)viewDidLoad
{
    _twitterApiManager = [[TWAPIManager alloc] init];
    
    if (IS_IPHONE_5)
        self.view.layer.contents = (id)[[VThemeManager sharedThemeManager] themedImageForKey:kVMenuBackgroundImage5].CGImage;
    else
        self.view.layer.contents = (id)[[VThemeManager sharedThemeManager] themedImageForKey:kVMenuBackgroundImage].CGImage;
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    UIGravityBehavior* gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.buttonContainer]];
    [self.animator addBehavior:gravityBehavior];
    
    UIDynamicItemBehavior *elasticityBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.buttonContainer]];
    elasticityBehavior.elasticity = 0.5f;
    [self.animator addBehavior:elasticityBehavior];
    
    UICollisionBehavior* collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.buttonContainer]];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    [self.animator addBehavior:collisionBehavior];
    
    self.facebookButton.layer.masksToBounds = YES;
    self.facebookButton.layer.cornerRadius = 40.0;
    self.facebookButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.facebookButton.layer.shouldRasterize = YES;
    self.facebookButton.clipsToBounds = YES;
    
    self.twitterButton.layer.masksToBounds = YES;
    self.twitterButton.layer.cornerRadius = 40.0;
    self.twitterButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.twitterButton.layer.shouldRasterize = YES;
    self.twitterButton.clipsToBounds = YES;
    
    self.emailButton.layer.masksToBounds = YES;
    self.emailButton.layer.cornerRadius = 40.0;
    self.emailButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.emailButton.layer.shouldRasterize = YES;
    self.emailButton.clipsToBounds = YES;
}

- (void)facebookAccessDidFail
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [self presentViewController:composeViewController animated:NO completion:^{
            [composeViewController dismissViewControllerAnimated:NO completion:nil];
        }];
    });
}

- (void)twitterAccessDidFail
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                       [self presentViewController:composeViewController animated:NO completion:^{
                           [composeViewController dismissViewControllerAnimated:NO completion:nil];
                       }];
                   });
}

#pragma mark - Actions

- (IBAction)facebookClicked:(id)sender
{
    ACAccountStore * const accountStore = [[ACAccountStore alloc] init];
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
                    [self facebookAccessDidFail];
                    break;
                }
                default:
                {
                    [self didFailWithError:error];
                    break;
                }
            }
            
            return;
        }
        else
        {
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            ACAccount* facebookAccount = [accounts lastObject];
            ACAccountCredential *fbCredential = [facebookAccount credential];
            NSString *accessToken = [fbCredential oauthToken];
 
             VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
             {
                 if (![[resultObjects firstObject] isKindOfClass:[VUser class]])
                     [self didFailWithError:nil];
                 
                 [self didLoginWithUser:[resultObjects firstObject]];
             };
             VFailBlock failed = ^(NSOperation* operation, NSError* error)
             {
                 VFailBlock     blockFail = ^(NSOperation* operation, NSError* error)
                 {
                     self.loginType = kVLoginTypeNone;
                     [self didFailWithError:error];
                 };
                 
                 if (error.code == 1003)
                 {
                     self.loginType = kVLoginTypeFaceBook;
                     [[VObjectManager sharedManager] loginToFacebookWithToken:accessToken SuccessBlock:success failBlock:blockFail];
                }
                 else
                     [self didFailWithError:error];
             };

            self.loginType = kVLoginTypeCreateFaceBook;
            [[VObjectManager sharedManager] createFacebookWithToken:accessToken
                                                        SuccessBlock:success
                                                           failBlock:failed];
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
                     [self twitterAccessDidFail];
                     break;
                 }
                 default:
                 {
                     [self didFailWithError:error];
                     break;
                 }
             }
             return;
         }
         else
         {
             NSArray *accounts = [account accountsWithAccountType:accountType];
             ACAccount *twitterAccount = [accounts lastObject];
 
             if (!twitterAccount)
             {
                 [self twitterAccessDidFail];
                 return;
             }
             
             [self.twitterApiManager performReverseAuthForAccount:twitterAccount
                                                      withHandler:^(NSData *responseData, NSError *error)
              {
                  VLog(@"data: %@, error:%@", responseData, error);

                  if (error)
                      [self didFailWithError:error];
                  
                  NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                  
                  //                TWDLog(@"Reverse Auth process returned: %@", responseStr);
                  
                  NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
                  NSMutableDictionary* parsedData = [[NSMutableDictionary alloc] initWithCapacity:[parts count]];
                  for (NSString* part in parts)
                  {
                      NSArray* data = [part componentsSeparatedByString:@"="];
                      if ([data count] < 2)
                          continue;
                      
                      [parsedData setObject:data[1] forKey:data[0]];
                  }
                  
                  NSString* oauthToken = [parsedData objectForKey:@"oauth_token"];
                  NSString* tokenSecret = [parsedData objectForKey:@"oauth_token_secret"];
                  NSString* twitterId = [parsedData objectForKey:@"user_id"];
                  
                  VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
                  {
                      if (![[resultObjects firstObject] isKindOfClass:[VUser class]])
                          [self didFailWithError:nil];
                      
                      [self didLoginWithUser:[resultObjects firstObject]];
                  };
                  VFailBlock failed = ^(NSOperation* operation, NSError* error)
                  {
                      VFailBlock     blockFail = ^(NSOperation* operation, NSError* error)
                      {
                          self.loginType = kVLoginTypeNone;
                          [self didFailWithError:error];
                      };
                      
                      if (error.code == 1003)
                      {
                          self.loginType = kVLoginTypeTwitter;
                          [[VObjectManager sharedManager] loginToTwitterWithToken:oauthToken
                                                                     accessSecret:tokenSecret
                                                                        twitterId:twitterId
                                                                     SuccessBlock:success failBlock:blockFail];
                      }
                      else
                          [self didFailWithError:error];
                  };
                  
                  self.loginType = kVLoginTypeCreateTwitter;
                  [[VObjectManager sharedManager] createTwitterWithToken:oauthToken
                                                            accessSecret:tokenSecret
                                                               twitterId:twitterId
                                                            SuccessBlock:success
                                                               failBlock:failed];
              }];
         }
    }];
}

- (void)didLoginWithUser:(VUser*)mainUser
{
    VLog(@"Succesfully logged in as: %@", mainUser);
    
    self.profile = mainUser;

    if (kVLoginTypeCreateFaceBook == self.loginType)
        [self performSegueWithIdentifier:@"toProfileWithFacebook" sender:self];
    else if (kVLoginTypeCreateTwitter == self.loginType)
        [self performSegueWithIdentifier:@"toProfileWithTwitter" sender:self];
    else
        [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didFailWithError:(NSError*)error
{
    UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginFail", @"")
                                                           message:error.localizedDescription
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                 otherButtonTitles:nil];
    [alert show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    VProfileWithSocialViewController*   profileViewController = (VProfileWithSocialViewController *)segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"toProfileWithFacebook"])
    {
        profileViewController.loginType = kVLoginTypeFaceBook;
        profileViewController.profile = self.profile;
    }
    else if ([segue.identifier isEqualToString:@"toProfileWithTwitter"])
    {
        profileViewController.loginType = kVLoginTypeTwitter;
        profileViewController.profile = self.profile;
    }
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
