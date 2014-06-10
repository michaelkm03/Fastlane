//
//  VUserProfileViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAnalyticsRecorder.h"
#import "VUserProfileViewController.h"
#import "VConstants.h"
#import "VUser.h"
#import "UIViewController+VSideMenuViewController.h"
#import "VLargeNumberFormatter.h"
#import "VLoginViewController.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Pagination.h"
#import "VStreamTableViewController+ContentCreation.h"
#import "VObjectManager+DirectMessaging.h"
#import "VProfileEditViewController.h"
#import "VFollowerTableViewController.h"
#import "VFollowingTableViewController.h"
#import "VMessageContainerViewController.h"
#import "UIImage+ImageEffects.h"
#import "UIImageView+Blurring.h"
#import "VThemeManager.h"
#import "VObjectManager+Login.h"

#import "VInboxContainerViewController.h"

const   CGFloat kVNavigationBarHeight = 44.0;

@interface VUserProfileViewController ()

@property   (nonatomic, strong) VUser*                  profile;
@property   (nonatomic) BOOL                            isMe;
@property   (nonatomic, strong) VLargeNumberFormatter*  largeNumberFormatter;

@property (nonatomic, strong) UIView*                   shortContainerView;
@property (nonatomic, strong) UIView*                   longContainerView;

@property (nonatomic, strong) UIImageView*              profileCircleImageView;
@property (nonatomic, strong) UIImageView*              backgroundImageView;

@property (nonatomic, strong) UILabel*                  nameLabel;
@property (nonatomic, strong) UILabel*                  locationLabel;
@property (nonatomic, strong) UILabel*                  taglineLabel;

@property (nonatomic, strong) UILabel*                  followersLabel;
@property (nonatomic, strong) UILabel*                  followersHeader;
@property (nonatomic, strong) UILabel*                  followingLabel;
@property (nonatomic, strong) UILabel*                  followingHeader;

@property (nonatomic, strong) UIButton*                 editProfileButton;
@property (nonatomic, strong) UIActivityIndicatorView*  followButtonActivityIndicator;

@end

@implementation VUserProfileViewController

+ (instancetype)userProfileWithSelf
{
    VUserProfileViewController*   viewController  =   [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateInitialViewController];
    
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Menu"]
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:viewController
                                                                                      action:@selector(showMenu:)];
    viewController.profile = [VObjectManager sharedManager].mainUser;
    
    return viewController;
}

+ (instancetype)userProfileWithUser:(VUser*)aUser
{
    VUserProfileViewController*   viewController  =   [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateInitialViewController];
    
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cameraButtonClose"]
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:viewController
                                                                                      action:@selector(close:)];
    viewController.profile = aUser;
    
    return viewController;
}

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    self.largeNumberFormatter = [[VLargeNumberFormatter alloc] init];
    self.isMe = (self.profile.remoteId.integerValue == [VObjectManager sharedManager].mainUser.remoteId.integerValue);
    
    if (self.isMe)
        self.navigationItem.title = NSLocalizedString(@"me", "");
    else
        self.navigationItem.title = self.profile.name ? [@"@" stringByAppendingString:self.profile.name] : @"Profile";
    
    [super viewDidLoad];
    
    if (self.isMe)
        [self addCreateButton];
    else if (!self.isMe)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profileCompose"]
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(composeMessage:)];
    
    self.tableView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];

    if (![VObjectManager sharedManager].mainUser)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStateDidChange:) name:kLoggedInChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
 
    UIImage*    defaultBackgroundImage;
    if (self.backgroundImageView.image)
        defaultBackgroundImage = self.backgroundImageView.image;
    else if (IS_IPHONE_5)
        defaultBackgroundImage = [[[VThemeManager sharedThemeManager] themedImageForKey:kVMenuBackgroundImage5] applyLightEffect];
    else
        defaultBackgroundImage = [[[VThemeManager sharedThemeManager] themedImageForKey:kVMenuBackgroundImage] applyLightEffect];
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.backgroundImageView setBlurredImageWithURL:[NSURL URLWithString:self.profile.pictureUrl]
                           placeholderImage:defaultBackgroundImage
                                  tintColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    self.tableView.backgroundView = self.backgroundImageView;
    
    defaultBackgroundImage = self.profileCircleImageView.image ? self.profileCircleImageView.image : [UIImage imageNamed:@"profileGenericUser"];
    [self.profileCircleImageView setImageWithURL:[NSURL URLWithString:self.profile.pictureUrl]
                                placeholderImage:defaultBackgroundImage];
    
    //If we came from the inbox we can get into a loop with the compose button, so hide it
    BOOL fromInbox = NO;
    for (UIViewController* vc in self.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:[VInboxContainerViewController class]])
            fromInbox = YES;
    }
    if (fromInbox)
        self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAppView:@"Profile"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] finishAppView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoggedInChangedNotification object:nil];
}

#pragma mark - Accessors

- (void)setProfile:(VUser *)profile
{
    _profile = profile;
    
    [self refreshFetchController];
}

#pragma mark - Support

- (void)setProfileData
{
    UIImage* defaultBackgroundImage = self.profileCircleImageView.image ? self.profileCircleImageView.image
                                                                        : [UIImage imageNamed:@"profileGenericUser"];
    [self.profileCircleImageView setImageWithURL:[NSURL URLWithString:self.profile.pictureUrl]
                                placeholderImage:defaultBackgroundImage];
    
    
    // Set Profile data
    self.nameLabel.text = self.profile.name;
    self.locationLabel.text = self.profile.location;
    
    if (self.profile.tagline && self.profile.tagline.length)
        self.taglineLabel.text = self.profile.tagline;

    [[VObjectManager sharedManager] countOfFollowsForUser:self.profile
         successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
         {
             self.followersLabel.text = [self.largeNumberFormatter stringForInteger:[resultObjects[0] integerValue]];
             self.followingLabel.text = [self.largeNumberFormatter stringForInteger:[resultObjects[1] integerValue]];
         }
         failBlock:^(NSOperation *operation, NSError *error)
         {
             self.followersLabel.text = [self.largeNumberFormatter stringForInteger:0];
             self.followingLabel.text = [self.largeNumberFormatter stringForInteger:0];
         }];
    
    if (!self.isMe)
    {
        if (self.editProfileButton.selected)
        {
            [self.editProfileButton setTitle:NSLocalizedString(@"following", @"") forState:UIControlStateNormal];
            self.editProfileButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.editProfileButton.backgroundColor = [UIColor clearColor];
        }
        else
        {
            [self.editProfileButton setTitle:NSLocalizedString(@"follow", @"") forState:UIControlStateNormal];
            self.editProfileButton.layer.borderColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor].CGColor;
            self.editProfileButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
        }
    }
}

- (UIView *)longHeader
{
    if (!self.longContainerView)
    {
        CGFloat     screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat     screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        self.longContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - kVNavigationBarHeight)];
        
        self.profileCircleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(120, 99, 80, 80)];
        self.profileCircleImageView.layer.cornerRadius = CGRectGetHeight(self.profileCircleImageView.bounds)/2;
        self.profileCircleImageView.layer.borderWidth = 2.0;
        self.profileCircleImageView.layer.borderColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor].CGColor;
        self.profileCircleImageView.clipsToBounds = YES;
        [self.longContainerView addSubview:self.profileCircleImageView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 196, screenWidth, 25)];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading1Font];
        self.nameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
        [self.longContainerView addSubview:self.nameLabel];
        
        self.locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 225, screenWidth, 25)];
        self.locationLabel.textAlignment = NSTextAlignmentCenter;
        self.locationLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
        self.locationLabel.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
        [self.longContainerView addSubview:self.locationLabel];
        
        self.taglineLabel = [[UILabel alloc] initWithFrame:CGRectMake(36, 255, screenWidth-72, 60)];
        self.taglineLabel.textAlignment = NSTextAlignmentCenter;
        self.taglineLabel.numberOfLines = 3;
        self.taglineLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
        self.taglineLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
        [self.longContainerView addSubview:self.taglineLabel];
        
        UIView* barView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight - 60 - 44, screenWidth, 60)];
        barView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.45];
        [self.longContainerView addSubview:barView];
        
        self.followersLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 100, 21)];
        self.followersLabel.textAlignment = NSTextAlignmentCenter;
        self.followersLabel.userInteractionEnabled = YES;
        [self.followersLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFollowers:)]];
        self.followersLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
        [barView addSubview:self.followersLabel];
        
        self.followersHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 100, 21)];
        self.followersHeader.text = NSLocalizedString(@"followers", @"");
        self.followersHeader.textAlignment = NSTextAlignmentCenter;
        self.followersHeader.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel4Font];
        [barView addSubview:self.followersHeader];
        
        self.followingLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - 100, 10, 100, 21)];
        self.followingLabel.textAlignment = NSTextAlignmentCenter;
        self.followingLabel.userInteractionEnabled = YES;
        [self.followingLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFollowing:)]];
        self.followingLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
        [barView addSubview:self.followingLabel];

        self.followingHeader = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - 100, 30, 100, 21)];
        self.followingHeader.text = NSLocalizedString(@"following", @"");
        self.followingHeader.textAlignment = NSTextAlignmentCenter;
        self.followingHeader.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel4Font];
        [barView addSubview:self.followingHeader];

        self.editProfileButton = [[UIButton alloc] initWithFrame:CGRectMake(105, 13, 110, 34)];
        self.editProfileButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton2Font];
        self.editProfileButton.layer.cornerRadius = 3.0;
        self.editProfileButton.layer.borderWidth = 2.0;
        [barView addSubview:self.editProfileButton];

        self.followButtonActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.followButtonActivityIndicator.center = CGPointMake(CGRectGetWidth(self.editProfileButton.frame) / 2.0, CGRectGetHeight(self.editProfileButton.frame) / 2.0);
        [self.editProfileButton addSubview:self.followButtonActivityIndicator];

        if (self.isMe)
        {
            [self.editProfileButton setTitle:NSLocalizedString(@"editProfileButton", @"") forState:UIControlStateNormal];
            [self.editProfileButton addTarget:self action:@selector(showProfileEdit:) forControlEvents:UIControlEventTouchUpInside];
            self.editProfileButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.editProfileButton.layer.borderWidth = 2.0;
            self.editProfileButton.backgroundColor = [UIColor clearColor];
            [self setProfileData];
        }
        else
        {
            [self.editProfileButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            if ([VObjectManager sharedManager].mainUser)
            {
                [[VObjectManager sharedManager] isUser:[VObjectManager sharedManager].mainUser
                                             following:self.profile
                                          successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
                 {
                     if ([resultObjects[0] boolValue])
                         self.editProfileButton.selected = YES;
                     [self setProfileData];
                 }
                                             failBlock:nil];
            }
            else
            {
                [self setProfileData];
            }
        }
    }
    else
    {
        [self setProfileData];
    }

    return self.longContainerView;
}

- (UIView *)shortHeader
{
    if (!self.shortContainerView)
    {
        CGFloat     screenHeight = 316;
        CGFloat     screenWidth = [UIScreen mainScreen].bounds.size.width;

        self.shortContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        
        self.profileCircleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(120, 25, 80, 80)];
        self.profileCircleImageView.layer.cornerRadius = CGRectGetHeight(self.profileCircleImageView.bounds)/2;
        self.profileCircleImageView.layer.borderWidth = 2.0;
        self.profileCircleImageView.layer.borderColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor].CGColor;
        self.profileCircleImageView.clipsToBounds = YES;
        [self.shortContainerView addSubview:self.profileCircleImageView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 122, screenWidth, 25)];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading1Font];
        self.nameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
        [self.shortContainerView addSubview:self.nameLabel];
        
        self.locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 151, screenWidth, 25)];
        self.locationLabel.textAlignment = NSTextAlignmentCenter;
        self.locationLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
        self.locationLabel.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
        [self.shortContainerView addSubview:self.locationLabel];
        
        self.taglineLabel = [[UILabel alloc] initWithFrame:CGRectMake(36, 181, screenWidth-72, 60)];
        self.taglineLabel.textAlignment = NSTextAlignmentCenter;
        self.taglineLabel.numberOfLines = 3;
        self.taglineLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
        self.taglineLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
        [self.shortContainerView addSubview:self.taglineLabel];
        
        UIView* barView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight - 60, screenWidth, 60)];
        barView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.45];
        [self.shortContainerView addSubview:barView];
        
        self.followersLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 100, 21)];
        self.followersLabel.textAlignment = NSTextAlignmentCenter;
        self.followersLabel.userInteractionEnabled = YES;
        [self.followersLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFollowers:)]];
        self.followersLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
        [barView addSubview:self.followersLabel];
        
        self.followersHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 100, 21)];
        self.followersHeader.text = NSLocalizedString(@"followers", @"");
        self.followersHeader.textAlignment = NSTextAlignmentCenter;
        self.followersHeader.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel4Font];
        [barView addSubview:self.followersHeader];
        
        self.followingLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - 100, 10, 100, 21)];
        self.followingLabel.textAlignment = NSTextAlignmentCenter;
        self.followingLabel.userInteractionEnabled = YES;
        [self.followingLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFollowing:)]];
        self.followingLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
        [barView addSubview:self.followingLabel];
        
        self.followingHeader = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - 100, 30, 100, 21)];
        self.followingHeader.text = NSLocalizedString(@"following", @"");
        self.followingHeader.textAlignment = NSTextAlignmentCenter;
        self.followingHeader.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel4Font];
        [barView addSubview:self.followingHeader];
        
        self.editProfileButton = [[UIButton alloc] initWithFrame:CGRectMake(105, 13, 110, 34)];
        self.editProfileButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton2Font];
        self.editProfileButton.layer.cornerRadius = 3.0;
        self.editProfileButton.layer.borderWidth = 2.0;
        [barView addSubview:self.editProfileButton];
        
        self.followButtonActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.followButtonActivityIndicator.center = CGPointMake(CGRectGetWidth(self.editProfileButton.frame) / 2.0, CGRectGetHeight(self.editProfileButton.frame) / 2.0);
        [self.editProfileButton addSubview:self.followButtonActivityIndicator];

        if (self.isMe)
        {
            [self.editProfileButton setTitle:NSLocalizedString(@"editProfileButton", @"") forState:UIControlStateNormal];
            [self.editProfileButton addTarget:self action:@selector(showProfileEdit:) forControlEvents:UIControlEventTouchUpInside];
            self.editProfileButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.editProfileButton.backgroundColor = [UIColor clearColor];
            [self setProfileData];
        }
        else
        {
            [self.editProfileButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            self.editProfileButton.layer.borderColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor].CGColor;
            
            if ([VObjectManager sharedManager].mainUser)
            {
                [[VObjectManager sharedManager] isUser:[VObjectManager sharedManager].mainUser
                                             following:self.profile
                                          successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
                 {
                     if ([resultObjects[0] boolValue])
                         self.editProfileButton.selected = YES;
                     [self setProfileData];
                 }
                                             failBlock:nil];
            }
            else
            {
                [self setProfileData];
            }
        }
    }
    else
    {
        [self setProfileData];
    }
    
    return self.shortContainerView;
}

- (void)loginStateDidChange:(NSNotification *)notification
{
    if ([VObjectManager sharedManager].mainUser)
    {
        [[VObjectManager sharedManager] isUser:[VObjectManager sharedManager].mainUser
                                     following:self.profile
                                  successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
         {
             if ([resultObjects[0] boolValue])
                 self.editProfileButton.selected = YES;
             [self setProfileData];
         }
                                     failBlock:nil];
    }
}

#pragma mark - Actions

- (IBAction)showMenu:(id)sender
{
    [self.sideMenuViewController presentMenuViewController];
}

- (IBAction)close:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)composeMessage:(id)sender
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:NSLocalizedString(@"BackButton", @"")
                                             style:UIBarButtonItemStylePlain
                                             target:nil
                                             action:nil];
    
    [[VObjectManager sharedManager] conversationWithUser:self.profile
                                            successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        VMessageContainerViewController*    composeController   = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"messageContainer"];
        composeController.conversation = [resultObjects firstObject];
        [self.navigationController pushViewController:composeController animated:YES];
    }
                                               failBlock:^(NSOperation* operation, NSError* error)
    {
        VLog(@"Failed with error: %@", error);
    }];
}

- (IBAction)showProfileEdit:(id)sender
{
    [self performSegueWithIdentifier:@"toEditProfile" sender:self];
}

- (IBAction)followButtonAction:(id)sender
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }

    self.editProfileButton.enabled = NO;
    [self.followButtonActivityIndicator startAnimating];

    if (self.editProfileButton.selected)
    {
        [[VObjectManager sharedManager] unfollowUser:self.profile
                                        successBlock:^(NSOperation *operation, id fullResponse, NSArray *objects)
         {
             self.editProfileButton.enabled = YES;
             self.editProfileButton.selected = NO;
             [self.followButtonActivityIndicator stopAnimating];
             [self setProfileData];
         }
                                           failBlock:^(NSOperation *operation, NSError *error)
         {
             self.editProfileButton.enabled = YES;
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
             self.editProfileButton.enabled = YES;
             self.editProfileButton.selected = YES;
             [self.followButtonActivityIndicator stopAnimating];
             [self setProfileData];
         }
                                         failBlock:^(NSOperation *operation, NSError *error)
         {
             self.editProfileButton.enabled = YES;
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

- (IBAction)showFollowers:(id)sender
{
    [self performSegueWithIdentifier:@"toFollowers" sender:self];
}

- (IBAction)showFollowing:(id)sender
{
    [self performSegueWithIdentifier:@"toFollowing" sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toEditProfile"])
    {
        VProfileEditViewController* controller = (VProfileEditViewController *)segue.destinationViewController;
        controller.profile = self.profile;
    }
    else if ([segue.identifier isEqualToString:@"toFollowers"])
    {
        VFollowerTableViewController*   controller = (VFollowerTableViewController *)segue.destinationViewController;
        controller.profile = self.profile;
    }
    else if ([segue.identifier isEqualToString:@"toFollowing"])
    {
        VFollowingTableViewController*   controller = (VFollowingTableViewController *)segue.destinationViewController;
        controller.profile = self.profile;
    }
}

#pragma mark - VStreamTableViewController

- (VSequenceFilter*)currentFilter
{
    return [[VObjectManager sharedManager] sequenceFilterForUser:self.profile];
}

- (IBAction)refresh:(UIRefreshControl *)sender
{
    [[VObjectManager sharedManager] refreshSequenceFilter:[self currentFilter]
                                             successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
                                              {
                                                  [self.refreshControl endRefreshing];
                                                  if (resultObjects.count > 0)
                                                  {
                                                      [UIView animateWithDuration:0.8 animations:^{
                                                          [self.tableView beginUpdates];
                                                          self.tableView.tableHeaderView = [self shortHeader];
                                                          
#warning - I just got a crash here: Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Invalid update: invalid number of sections.  The number of sections contained in the table view after the update (0) must be equal to the number of sections contained in the table view before the update (1), plus or minus the number of sections inserted or deleted (0 inserted, 0 deleted).'  I think this is a race condition caused because the fetchedresultscontroller is also updating.  Gary can we talk about this tomorrow?
                                                          
                                                          [self.tableView endUpdates];
                                                      }];
                                                  }
                                                  else
                                                  {
                                                      [UIView animateWithDuration:0.8 animations:^{
                                                          [self.tableView beginUpdates];
                                                          self.tableView.tableHeaderView = [self longHeader];
                                                          [self.tableView endUpdates];
                                                      }];
                                                 }
                                              }
                                              failBlock:^(NSOperation* operation, NSError* error)
                                              {
                                                  [self.refreshControl endRefreshing];
                                                  [UIView animateWithDuration:0.8 animations:^{
                                                      [self.tableView beginUpdates];
                                                      self.tableView.tableHeaderView = [self longHeader];
                                                      [self.tableView endUpdates];
                                                  }];

                                              }];
}

@end
