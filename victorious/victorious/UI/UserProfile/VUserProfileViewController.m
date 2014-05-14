//
//  VUserProfileViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUserProfileViewController.h"
#import "VConstants.h"
#import "UIViewController+VSideMenuViewController.h"
#import "VLoginViewController.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+SequenceFilters.h"
#import "VStreamTableViewController+ContentCreation.h"
#import "VObjectManager+DirectMessaging.h"
#import "VProfileEditViewController.h"
#import "VFollowerTableViewController.h"
#import "VFollowingTableViewController.h"
#import "VMessageContainerViewController.h"
#import "UIImage+ImageEffects.h"
#import "UIImageView+Blurring.h"
#import "VUser+LoadFollowers.h"
#import "VThemeManager.h"

const   CGFloat kVNavigationBarHeight = 44.0;

@interface VUserProfileViewController ()

@property   (nonatomic) VUserProfileUserID              userID;
@property   (nonatomic, strong) VUser*                  profile;

@property   (nonatomic)       BOOL                      isMe;

@property (nonatomic, strong) UIView*                   shortContainerView;
@property (nonatomic, strong) UIView*                   longContainerView;

@property (nonatomic, strong) UIImageView*              backgroundImageView;
@property (nonatomic, strong) UIImageView*              profileCircleImageView;

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
    viewController.userID = -1;

    return viewController;
}

+ (instancetype)userProfileWithUserID:(VUserProfileUserID)aUserID
{
    VUserProfileViewController*   viewController  =   [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateInitialViewController];
    
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cameraButtonClose"]
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:viewController
                                                                                      action:@selector(close:)];
    viewController.userID = aUserID;

    return viewController;
}

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    self.isMe = ((kVProfileUserIDSelf == self.userID) || (self.userID == [[VObjectManager sharedManager].mainUser.remoteId integerValue]));
    
    if (self.isMe)
    {
        self.profile = [VObjectManager sharedManager].mainUser;
        self.navigationItem.title = NSLocalizedString(@"me", "");
    }
    else
    {
        [[VObjectManager sharedManager] fetchUser:@(self.userID) withSuccessBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
         {
             self.profile = [resultObjects firstObject];
             self.navigationItem.title = [@"@" stringByAppendingString:self.profile.name];
         }
         failBlock:^(NSOperation* operation, NSError* error)
         {
             VLog("Profile failed to get User object");
         }];
    }
    
    [super viewDidLoad];
    
    if (self.isMe)
    {
        [self addCreateButton];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profileCompose"]
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(composeMessage:)];
    }

    self.tableView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.tableView.tableHeaderView = [self longHeader];
    
    if (!self.isMe)
        [[VObjectManager sharedManager] addObserver:self forKeyPath:NSStringFromSelector(@selector(mainUser)) options:(NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (!self.isMe)
    {
        if ([[VObjectManager sharedManager] mainUser])
            [[[VObjectManager sharedManager] mainUser] removeObserver:self forKeyPath:NSStringFromSelector(@selector(followingListLoading))];

        [[VObjectManager sharedManager] removeObserver:self forKeyPath:NSStringFromSelector(@selector(mainUser))];
    }
}

#pragma mark - Support

- (void)setProfileData
{
    //  Set background profile image
    NSURL*  imageURL    =   [NSURL URLWithString:self.profile.pictureUrl];
    
    UIImage*    defaultBackgroundImage;
    if (IS_IPHONE_5)
        defaultBackgroundImage = [[[VThemeManager sharedThemeManager] themedImageForKey:kVMenuBackgroundImage5] applyLightEffect];
    else
        defaultBackgroundImage = [[[VThemeManager sharedThemeManager] themedImageForKey:kVMenuBackgroundImage] applyLightEffect];

    [self.backgroundImageView setBlurredImageWithURL:imageURL
                                    placeholderImage:defaultBackgroundImage
                                           tintColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    [self.profileCircleImageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"profileGenericUser"]];

    // Set Profile data
    self.nameLabel.text = self.profile.name;
    self.locationLabel.text = self.profile.location;
    
    if (self.profile.tagline && self.profile.tagline.length)
        self.taglineLabel.text = self.profile.tagline;

    VSuccessBlock followerSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        self.followersLabel.text = [self formattedStringForCount:[self.profile.followers count]];
    };
   
    VSuccessBlock followingSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        self.followingLabel.text = [self formattedStringForCount:[self.profile.following count]];
    };

    if (!self.profile.followerListLoading)
         [[VObjectManager sharedManager] requestFollowerListForUser:self.profile
                                                      successBlock:followerSuccess
                                                         failBlock:nil];
    else
        followerSuccess(nil, nil, nil);

    if (!self.profile.followingListLoading)
        [[VObjectManager sharedManager] requestFollowListForUser:self.profile
                                                    successBlock:followingSuccess
                                                       failBlock:nil];
    else
        followingSuccess(nil, nil, nil);
        
    if (self.isMe)
    {
        [self.editProfileButton setTitle:NSLocalizedString(@"editProfileButton", @"") forState:UIControlStateNormal];
        [self.editProfileButton addTarget:self action:@selector(showProfileEdit:) forControlEvents:UIControlEventTouchUpInside];
        self.editProfileButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.editProfileButton.layer.borderWidth = 2.0;
        self.editProfileButton.layer.cornerRadius = 3.0;
        self.editProfileButton.backgroundColor = [UIColor clearColor];
    }
    else
    {
        [self.editProfileButton setTitle:NSLocalizedString(@"follow", @"") forState:UIControlStateNormal];
        [self.editProfileButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.editProfileButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.editProfileButton.layer.borderWidth = 0.0;
        self.editProfileButton.layer.cornerRadius = 3.0;
        self.editProfileButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
        
        if ([[[[VObjectManager sharedManager].mainUser following] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"remoteId=%d", (int)self.userID]] count])
        {
            [self.editProfileButton setTitle:NSLocalizedString(@"following", @"") forState:UIControlStateNormal];
            self.editProfileButton.layer.borderWidth = 2.0;
            self.editProfileButton.selected = YES;
        }
        
        self.followButtonActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.followButtonActivityIndicator.center = CGPointMake(CGRectGetWidth(self.editProfileButton.frame) / 2.0, CGRectGetHeight(self.editProfileButton.frame) / 2.0);
        [self.editProfileButton addSubview:self.followButtonActivityIndicator];
    }
}

- (NSString *)formattedStringForCount:(CGFloat)count
{
    if (0.0 == count)
        return @"Zero";

    static  NSNumberFormatter*  formatter;
    static  dispatch_once_t     onceToken;
    static const char sUnits[] = { '\0', 'K', 'M', 'G' };
    static int sMaxUnits = sizeof sUnits - 1;
    
    int multiplier = 1000;
    int exponent = 0;
    
    dispatch_once(&onceToken, ^{
        formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        formatter.maximumFractionDigits = 2;
    });
        
    while ((count >= multiplier) && (exponent < sMaxUnits))
    {
        count /= multiplier;
        exponent++;
    }
    
    return [NSString stringWithFormat:@"%@ %c", [formatter stringFromNumber:@(count)], sUnits[exponent]];
}

- (UIView *)longHeader
{
    if (self.longContainerView)
        return self.longContainerView;

    CGFloat     screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat     screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    self.longContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - kVNavigationBarHeight)];
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.longContainerView.frame];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.clipsToBounds = YES;
    [self.longContainerView addSubview:self.backgroundImageView];
    
    self.profileCircleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(120, 99, 80, 80)];
    self.profileCircleImageView.layer.cornerRadius = CGRectGetHeight(self.profileCircleImageView.bounds)/2;
    self.profileCircleImageView.layer.borderWidth = 1.0;
    self.profileCircleImageView.layer.borderColor = [UIColor whiteColor].CGColor;
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
    [barView addSubview:self.editProfileButton];

    [self setProfileData];

    return self.longContainerView;
}

- (UIView *)shortHeader
{
    if (self.shortContainerView)
        return self.shortContainerView;

    CGFloat     screenHeight = 316;
    CGFloat     screenWidth = [UIScreen mainScreen].bounds.size.width;

    self.shortContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.shortContainerView.frame];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.clipsToBounds = YES;
    [self.shortContainerView addSubview:self.backgroundImageView];
    
    self.profileCircleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(120, 25, 80, 80)];
    self.profileCircleImageView.layer.cornerRadius = CGRectGetHeight(self.profileCircleImageView.bounds)/2;
    self.profileCircleImageView.layer.borderWidth = 1.0;
    self.profileCircleImageView.layer.borderColor = [UIColor whiteColor].CGColor;
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
    [barView addSubview:self.editProfileButton];
    
    [self setProfileData];
    
    return self.shortContainerView;
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

    VMessageContainerViewController*    composeController   = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"messageContainer"];
    composeController.conversation = [[VObjectManager sharedManager] conversationWithUser:self.profile];
    [self.navigationController pushViewController:composeController animated:YES];
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
             [self.editProfileButton setTitle:NSLocalizedString(@"follow", @"") forState:UIControlStateNormal];
             self.editProfileButton.layer.borderColor = [UIColor whiteColor].CGColor;
             self.editProfileButton.layer.borderWidth = 0.0;
             self.editProfileButton.layer.cornerRadius = 3.0;
             self.editProfileButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
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
             [self.editProfileButton setTitle:NSLocalizedString(@"following", @"") forState:UIControlStateNormal];
             self.editProfileButton.layer.borderColor = [UIColor whiteColor].CGColor;
             self.editProfileButton.layer.borderWidth = 2.0;
             self.editProfileButton.layer.cornerRadius = 3.0;
             self.editProfileButton.backgroundColor = [UIColor clearColor];
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
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@""
                                             style:UIBarButtonItemStylePlain
                                             target:nil
                                             action:nil];

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

#pragma mark - Key-Value Observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == [VObjectManager sharedManager] && [keyPath isEqualToString:NSStringFromSelector(@selector(mainUser))])
    {
        VUser *oldUser = change[NSKeyValueChangeOldKey];
        if ([oldUser isKindOfClass:[VUser class]])
        {
            [oldUser removeObserver:self forKeyPath:NSStringFromSelector(@selector(followingListLoading))];
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
            self.editProfileButton.enabled = NO;
            [self.followButtonActivityIndicator startAnimating];
        }
        else
        {
            self.editProfileButton.enabled = YES;
            [self.followButtonActivityIndicator stopAnimating];
            [self setProfileData];
        }
    }
}

#pragma mark - VStreamTableViewController

- (VSequenceFilter*)currentFilter
{
    return [[VObjectManager sharedManager] sequenceFilterForUser:self.profile];
}

- (IBAction)refreshAction:(id)sender
{
    RKManagedObjectRequestOperation* operation = [[VObjectManager sharedManager] refreshSequenceFilter:[self currentFilter]
                                                                                          successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
                                                  {
                                                      [self.refreshControl endRefreshing];
                                                      
                                                      if (resultObjects.count > 0)
                                                      {
                                                          [UIView animateWithDuration:0.6 animations:^{
                                                              [self.tableView beginUpdates];
                                                              self.tableView.tableHeaderView = [self shortHeader];
                                                              [self.tableView endUpdates];
                                                              [self setProfileData];
                                                          }];
                                                      }
                                                      else
                                                      {
                                                          [UIView animateWithDuration:0.6 animations:^{
                                                              [self.tableView beginUpdates];
                                                              self.tableView.tableHeaderView = [self longHeader];
                                                              [self.tableView endUpdates];
                                                              [self setProfileData];
                                                          }];
                                                     }
                                                  }
                                                                                             failBlock:^(NSOperation* operation, NSError* error)
                                                  {
                                                      [self.refreshControl endRefreshing];
                                                      [UIView animateWithDuration:0.6 animations:^{
                                                          [self.tableView beginUpdates];
                                                          self.tableView.tableHeaderView = [self longHeader];
                                                          [self.tableView endUpdates];
                                                          [self setProfileData];
                                                      }];

                                                  }];
    
    if (operation)
    {
        [self.refreshControl beginRefreshing];
    }
}

@end
