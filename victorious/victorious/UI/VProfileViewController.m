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
#import "VUser+LoadFollowers.h"
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
@property (nonatomic, weak) IBOutlet UIButton* followButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* followButtonActivityIndicator;

@end

@implementation VProfileViewController

+ (VProfileViewController *)profileViewController
{
    UIViewController       *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VProfileViewController *profileViewController = (VProfileViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier:@"profile"];
    return profileViewController;
}

+ (instancetype)profileWithSelf
{
    VProfileViewController *profileViewController = [self profileViewController];
    profileViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Menu"]
                                                                                              style:UIBarButtonItemStylePlain
                                                                                             target:profileViewController
                                                                                             action:@selector(showMenu:)];
    profileViewController.userID = -1;
    return profileViewController;
}

+ (instancetype)profileWithUserID:(VProfileUserID)aUserID
{
    VProfileViewController *profileViewController = [self profileViewController];
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

    UIImage *followSelectedImage = [self.followButton imageForState:UIControlStateSelected];
    [self.followButton setImage:followSelectedImage forState:UIControlStateSelected | UIControlStateHighlighted];
    [self.followButton setImage:followSelectedImage forState:UIControlStateSelected | UIControlStateDisabled];
    
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
    
    [[VObjectManager sharedManager] addObserver:self forKeyPath:NSStringFromSelector(@selector(mainUser)) options:(NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if ([[VObjectManager sharedManager] mainUser])
    {
        [[[VObjectManager sharedManager] mainUser] removeObserver:self forKeyPath:NSStringFromSelector(@selector(followingListLoading))];
    }
    [[VObjectManager sharedManager] removeObserver:self forKeyPath:NSStringFromSelector(@selector(mainUser))];
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
    
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];
    if (self.userID == kProfileUserIDSelf || [mainUser.remoteId isEqualToNumber:self.profile.remoteId])
    {
        self.followButton.hidden = YES;
    }
    else if ([[[mainUser following] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"remoteId=%d", (int)self.userID]] count])
    {
        self.followButton.selected = YES;
    }
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

- (IBAction)followButtonAction:(id)sender
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }

    self.followButton.enabled = NO;
    [self.followButtonActivityIndicator startAnimating];

    if (self.followButton.selected)
    {
        [[VObjectManager sharedManager] unfollowUser:self.profile
                                        successBlock:^(NSOperation *operation, id fullResponse, NSArray *objects)
        {
            self.followButton.enabled = YES;
            self.followButton.selected = NO;
            [self.followButtonActivityIndicator stopAnimating];
        }
                                           failBlock:^(NSOperation *operation, NSError *error)
        {
            self.followButton.enabled = YES;
            [self.followButtonActivityIndicator stopAnimating];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"UnfollowError", @"")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                  otherButtonTitles:nil];
            [alert show];
        }];
    }
    else
    {
        [[VObjectManager sharedManager] followUser:self.profile
                                      successBlock:^(NSOperation *operation, id fullResponse, NSArray *objects)
        {
            self.followButton.enabled = YES;
            self.followButton.selected = YES;
            [self.followButtonActivityIndicator stopAnimating];
        }
                                         failBlock:^(NSOperation *operation, NSError *error)
        {
            self.followButton.enabled = YES;
            [self.followButtonActivityIndicator stopAnimating];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"FollowError", @"")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                  otherButtonTitles:nil];
            [alert show];
        }];
    }
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

#pragma mark - Key-Value Observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == [VObjectManager sharedManager])
    {
        VUser *oldUser = change[NSKeyValueChangeOldKey];
        if ([oldUser isKindOfClass:[VUser class]])
        {
            [oldUser removeObserver:self forKeyPath:NSStringFromSelector(@selector(mainUser))];
        }
        VUser *newUser = change[NSKeyValueChangeNewKey];
        if ([newUser isKindOfClass:[VUser class]])
        {
            [newUser addObserver:self forKeyPath:NSStringFromSelector(@selector(followingListLoading)) options:NSKeyValueObservingOptionInitial context:NULL];
            if (!newUser.followingListLoaded && !newUser.followingListLoading)
            {
                [[VObjectManager sharedManager] requestFollowListForUser:newUser successBlock:nil failBlock:nil];
            }
        }
    }
    else if (object == [[VObjectManager sharedManager] mainUser] && [keyPath isEqualToString:NSStringFromSelector(@selector(followingListLoading))])
    {
        if ([[[VObjectManager sharedManager] mainUser] followingListLoading])
        {
            self.followButton.enabled = NO;
            [self.followButtonActivityIndicator startAnimating];
        }
        else
        {
            self.followButton.enabled = YES;
            [self.followButtonActivityIndicator stopAnimating];
            [self setProfileData];
        }
    }
}

@end
