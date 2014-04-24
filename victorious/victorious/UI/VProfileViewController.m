//
//  VProfileViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileViewController.h"
#import "UIViewController+VSideMenuViewController.h"
#import "VObjectManager+Login.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+DirectMessaging.h"
#import "VProfileEditViewController.h"
#import "VMessageViewController.h"
#import "VUser.h"
#import "VThemeManager.h"
#import "VLoginViewController.h"
#import "UIImage+ImageEffects.h"
#import "UIImageView+Blurring.h"

@interface VProfileViewController () <UIActionSheetDelegate>
@property   (nonatomic) VProfileUserID      userID;
@property   (nonatomic, strong) VUser*      profile;

@property (nonatomic, weak) IBOutlet UIImageView* backgroundImageView;
@property (nonatomic, weak) IBOutlet UIImageView* profileCircleImageView;
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UILabel* taglineLabel;
@property (nonatomic, weak) IBOutlet UILabel* locationLabel;

@end

@implementation VProfileViewController

+ (instancetype)profileWithSelf
{
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VProfileViewController* profileViewController = (VProfileViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: @"profile"];
    
    profileViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Menu"]
                                                                                              style:UIBarButtonItemStylePlain
                                                                                             target:profileViewController
                                                                                             action:@selector(showMenu:)];
    profileViewController.userID = -1;
    return profileViewController;
}

+ (instancetype)profileWithUserID:(VProfileUserID)aUserID
{
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VProfileViewController* profileViewController = (VProfileViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: @"profile"];

    profileViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                                           target:profileViewController
                                                                                                           action:@selector(closeButtonAction:)];

    profileViewController.userID = aUserID;

    return profileViewController;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ((-1 == self.userID) || (self.userID == [VObjectManager sharedManager].mainUser.remoteId.integerValue))
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                               target:self
                                                                                               action:@selector(editButtonAction:)];
        self.profile = [VObjectManager sharedManager].mainUser;
        [self setProfileData];
    }
    else
    {
        UIBarButtonItem* composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                       target:self
                                                                                       action:@selector(composeButtonAction:)];
        self.navigationItem.rightBarButtonItem = composeButton;

        [[VObjectManager sharedManager] fetchUser:@(self.userID)
                                 withSuccessBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
                                 {
                                     self.profile = [resultObjects firstObject];
                                     [self setProfileData];
                                 }
                                        failBlock:^(NSOperation* operation, NSError* error)
                                        {
                                            VLog("Profile failed to get User object");
                                        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setProfileData];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setProfileData
{
    //  Set background profile image
    NSURL*  imageURL    =   [NSURL URLWithString:self.profile.pictureUrl];
//    [self.backgroundImageView setBlurredImageWithURL:imageURL
//                                    placeholderImage:[UIImage imageNamed:@"profile_full"]
//                                           tintColor:[UIColor colorWithWhite:1.0 alpha:0.3]];

    self.profileCircleImageView.layer.masksToBounds = YES;
    self.profileCircleImageView.layer.cornerRadius = CGRectGetHeight(self.profileCircleImageView.bounds)/2;
    self.profileCircleImageView.layer.borderWidth = 2.0;
    UIColor* tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.profileCircleImageView.layer.borderColor = tintColor.CGColor;
    self.profileCircleImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.profileCircleImageView.layer.shouldRasterize = YES;
    self.profileCircleImageView.clipsToBounds = YES;
    [self.profileCircleImageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"profile_thumb"]];

    // Set Profile data
    self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
    self.nameLabel.text = self.profile.name;
    self.taglineLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];

    if (self.profile.tagline && self.profile.tagline.length)
        self.taglineLabel.text = [NSString stringWithFormat:@"%@%@%@",
                                  [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleQuotationBeginDelimiterKey],
                                  self.profile.tagline,
                                  [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleQuotationEndDelimiterKey]];
    else
        self.taglineLabel.text = @"";

    self.locationLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    self.locationLabel.text = self.profile.location;
    self.locationLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];

    self.navigationItem.title = self.profile.name;
}

#pragma mark - Actions

- (IBAction)editButtonAction:(id)sender
{
    [self performSegueWithIdentifier:@"toEditProfile" sender:self];
}

-(IBAction)composeButtonAction:(id)sender
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }

    [self performSegueWithIdentifier:@"toComposeMessage" sender:self];
}

- (IBAction)showMenu:(id)sender
{
    [self.sideMenuViewController presentMenuViewController];
}

- (IBAction)closeButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toEditProfile"])
    {
        VProfileEditViewController* controller = (VProfileEditViewController *)segue.destinationViewController;
        controller.profile = self.profile;
    }
    else if ([segue.identifier isEqualToString:@"toComposeMessage"])
    {
        VMessageViewController *subview = (VMessageViewController *)segue.destinationViewController;
        subview.conversation = [[VObjectManager sharedManager] conversationWithUser:self.profile];
    }
}

@end
