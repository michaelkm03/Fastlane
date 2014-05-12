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
//#import "VObjectManager+Login.h"
//#import "VObjectManager+DirectMessaging.h"
//#import "VProfileEditViewController.h"
//#import "VMessageViewController.h"
#import "UIImage+ImageEffects.h"
#import "UIImageView+Blurring.h"
#import "VProgressiveImageView.h"
#import "VUser+LoadFollowers.h"
#import "VThemeManager.h"

@interface VUserProfileViewController ()

@property   (nonatomic) VUserProfileUserID                      userID;
@property   (nonatomic, strong) VUser*                          profile;

@property (nonatomic, weak) IBOutlet    UIImageView*            backgroundImageView;
@property (nonatomic, weak) IBOutlet    UIView*                 profileCircleImageView;

@property (nonatomic, weak) IBOutlet    UILabel*                nameLabel;
@property (nonatomic, weak) IBOutlet    UILabel*                taglineLabel;
@property (nonatomic, weak) IBOutlet    UILabel*                locationLabel;

@property (nonatomic, weak) IBOutlet    UILabel*                followersLabel;
@property (nonatomic, weak) IBOutlet    UILabel*                followersHeader;
@property (nonatomic, weak) IBOutlet    UILabel*                followingLabel;
@property (nonatomic, weak) IBOutlet    UILabel*                followingHeader;

@property (nonatomic, weak) IBOutlet    UIButton*               editProfileButton;
@property (nonatomic, weak) IBOutlet    UIButton*               followButton;
@property (nonatomic, weak) IBOutlet    UIActivityIndicatorView* followButtonActivityIndicator;

@end

@implementation VUserProfileViewController
{
    CGFloat _startContentOffset;
    CGFloat _lastContentOffset;
}

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
    [super viewDidLoad];

    if ((kVProfileUserIDSelf == self.userID) || (self.userID == [[VObjectManager sharedManager].mainUser.remoteId integerValue]))
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profileAddContent"]
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(addContent:)];
        self.editProfileButton.hidden = NO;
        self.followButton.hidden = YES;

        self.profile = [VObjectManager sharedManager].mainUser;
        self.navigationItem.title = @"ME";

        self.editProfileButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.editProfileButton.layer.borderWidth = 2.0;
        self.editProfileButton.layer.cornerRadius = 3.0;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profileCompose"]
                                                                                            style:UIBarButtonItemStylePlain
                                                                                           target:self
                                                                                           action:@selector(composeMessage:)];
        self.editProfileButton.hidden = YES;
        self.followButton.hidden = NO;
        
        UIImage *followSelectedImage = [[UIImage imageNamed:@"followingButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.followButton setImage:followSelectedImage forState:UIControlStateSelected];
        [self.followButton setImage:followSelectedImage forState:UIControlStateSelected | UIControlStateHighlighted];
        [self.followButton setImage:followSelectedImage forState:UIControlStateSelected | UIControlStateDisabled];
        self.followButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];

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
    
    self.tableView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    
    [self createStreamIfNecessary];
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

    VProgressiveImageView*  imageView = [[VProgressiveImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.profileCircleImageView.bounds), CGRectGetHeight(self.profileCircleImageView.bounds))];
    [self.profileCircleImageView addSubview:imageView];
    [imageView setImageURL:imageURL];

    // Set Profile data
    self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading1Font];
    self.nameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    self.nameLabel.text = self.profile.name;
    
    self.taglineLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
    self.taglineLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    if (self.profile.tagline && self.profile.tagline.length)
        self.taglineLabel.text = self.profile.tagline;

    self.locationLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    self.locationLabel.text = self.profile.location;
    self.locationLabel.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    
    if ([[[[VObjectManager sharedManager].mainUser following] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"remoteId=%d", (int)self.userID]] count])
    {
        self.followButton.selected = YES;
    }
    
    self.followersHeader.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel4Font];
    self.followersLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    self.followersLabel.text = [self formattedStringForCount:0];
    self.followingHeader.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel4Font];
    self.followingLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    self.followingLabel.text = [self formattedStringForCount:7526854];
    
    self.editProfileButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton2Font];
}

- (void)createStreamIfNecessary
{
    return;
    
    //  Does this user have any stream entries
    //  YES -
    
    CGRect  newRect = CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, 320.0);
    UIView* tblHeader = self.tableView.tableHeaderView;
    
    [UIView animateWithDuration:0.6 animations:^{
        tblHeader.frame = newRect;
        self.tableView.tableHeaderView = tblHeader;
    }];

    //      populate stream
}

- (NSString *)formattedStringForCount:(CGFloat)count
{
//    static  NSByteCountFormatter*       formatter;
//    static  dispatch_once_t             onceToken;
//    
//    dispatch_once(&onceToken, ^{
//        formatter = [[NSByteCountFormatter alloc] init];
//        formatter.countStyle = NSByteCountFormatterCountStyleDecimal;
//        formatter.includesUnit = NO;
//    });
//    
//    return [formatter stringFromByteCount:count];

    if (0.0 == count)
        return @"Zero";

    static  NSNumberFormatter*  formatter;
    static  dispatch_once_t     onceToken;
    static const char sUnits[] = { '\0', 'K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y' };
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

#pragma mark - Actions

- (IBAction)showMenu:(id)sender
{
    [self.sideMenuViewController presentMenuViewController];
}

- (IBAction)close:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addContent:(id)sender
{
    
}

- (IBAction)composeMessage:(id)sender
{
    //    if (![VObjectManager sharedManager].mainUser)
    //    {
    //        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
    //        return;
    //    }
    //
    //    [self performSegueWithIdentifier:@"toComposeMessage" sender:self];
}

- (IBAction)editProfile:(id)sender
{
//    [self performSegueWithIdentifier:@"toEditProfile" sender:self];
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
//    if ([segue.identifier isEqualToString:@"toEditProfile"])
//    {
//        VProfileEditViewController* controller = (VProfileEditViewController *)segue.destinationViewController;
//        controller.profile = self.profile;
//    }
//    else if ([segue.identifier isEqualToString:@"toComposeMessage"])
//    {
//        VMessageViewController *subview = (VMessageViewController *)segue.destinationViewController;
//        subview.conversation = [[VObjectManager sharedManager] conversationWithUser:self.profile];
//    }
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

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _startContentOffset = _lastContentOffset = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat differenceFromStart = _startContentOffset - currentOffset;
    CGFloat differenceFromLast = _lastContentOffset - currentOffset;
    _lastContentOffset = currentOffset;
    
    if ((differenceFromStart) < 0)
    {
        if (scrollView.isTracking && (abs(differenceFromLast)>1))
            [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    else
    {
        if (scrollView.isTracking && (abs(differenceFromLast)>1))
            [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"stream"];
}

@end
