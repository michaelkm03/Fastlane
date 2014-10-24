//
//  VUserProfileViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUserProfileViewController.h"
#import "VUser.h"
#import "UIViewController+VSideMenuViewController.h"
#import "VLoginViewController.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Pagination.h"
#import "VStreamTableDataSource.h"
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

#import "VStream+Fetcher.h"

#import "VObjectManager+ContentCreation.h"

#import "VInboxContainerViewController.h"

#import "VUserProfileHeaderView.h"

#import "VAuthorizationViewControllerFactory.h"

#import "UIViewController+VNavMenu.h"
#import "VSettingManager.h"

static const CGFloat kVSmallUserHeaderHeight = 319.0f;

static void * VUserProfileViewContext = &VUserProfileViewContext;

@interface VUserProfileViewController () <VUserProfileHeaderDelegate, VNavigationHeaderDelegate>

@property   (nonatomic, strong) VUser                  *profile;

@property (nonatomic, strong) VUserProfileHeaderView *profileHeaderView;
@property (nonatomic, strong) UIImageView              *backgroundImageView;
@property (nonatomic) BOOL                            isMe;

@end

@implementation VUserProfileViewController

+ (instancetype)userProfileWithUser:(VUser *)aUser
{
    VUserProfileViewController   *viewController  =   [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateInitialViewController];
    viewController.profile = aUser;
    
    BOOL isMe = (aUser.remoteId.integerValue == [VObjectManager sharedManager].mainUser.remoteId.integerValue);
    
    if (isMe)
    {
        viewController.title = NSLocalizedString(@"me", "");
    }
    else
    {
        viewController.title = aUser.name ?: @"Profile";
    }

    return viewController;
}

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isMe = (self.profile.remoteId.integerValue == [VObjectManager sharedManager].mainUser.remoteId.integerValue);
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    VUserProfileHeaderView *headerView =  [VUserProfileHeaderView newViewWithFrame:CGRectMake(0, 0, screenWidth,
                                                                                              screenHeight - CGRectGetHeight(self.navHeaderView.frame))];
    headerView.user = self.profile;
    headerView.delegate = self;
    self.profileHeaderView = headerView;
    self.refreshControl.layer.zPosition = self.profileHeaderView.layer.zPosition + 1;

    UIColor *backgroundColor = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled] ? [UIColor clearColor] : [[VThemeManager sharedThemeManager] preferredBackgroundColor];
    self.collectionView.backgroundColor = backgroundColor;
    
    if (![VObjectManager sharedManager].mainUser)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStateDidChange:) name:kLoggedInChangedNotification object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self addNewNavHeaderWithTitles:nil];
    self.navHeaderView.delegate = self;
    
    //    if (self.isMe)
    //    {
    //        [self addFriendsButton];
    //    }
    //    else
    if (!self.isMe && !self.profile.isDirectMessagingDisabled.boolValue)
    {
        [self.navHeaderView setRightButtonImage:[UIImage imageNamed:@"profileCompose"] withAction:@selector(composeMessage:) onTarget:self];
    }
    
    self.profileHeaderView.user = self.profile;
    
    [super viewWillAppear:animated]; //Call super after the header is set up so the super class will set up the headers properly.
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
 
    UIImage    *defaultBackgroundImage;
    if (self.backgroundImageView.image)
    {
        defaultBackgroundImage = self.backgroundImageView.image;
    }
    else
    {
        defaultBackgroundImage = [[[VThemeManager sharedThemeManager] themedBackgroundImageForDevice] applyLightEffect];
    }
    
    [self.backgroundImageView removeFromSuperview];
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.backgroundImageView setBlurredImageWithURL:[NSURL URLWithString:self.profile.pictureUrl]
                           placeholderImage:defaultBackgroundImage
                                  tintColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    [self.view insertSubview:self.backgroundImageView belowSubview:self.collectionView];
    
    if (self.streamDataSource.count)
    {
        [self animateHeaderShrinkingWithDuration:0.0f];
    }
    
    //If we came from the inbox we can get into a loop with the compose button, so hide it
    BOOL fromInbox = NO;
    for (UIViewController *vc in self.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:[VInboxContainerViewController class]])
        {
            fromInbox = YES;
        }
    }
    if (fromInbox)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoggedInChangedNotification object:nil];
}

#pragma mark - Accessors

- (NSString *)viewName
{
    return @"Profile";
}

- (void)setProfile:(VUser *)profile
{
    _profile = profile;
    self.currentStream = [VStream streamForUser:self.profile];
    if ([self isViewLoaded])
    {
        [self refresh:nil];
    }
}

#pragma mark - Support

- (void)loginStateDidChange:(NSNotification *)notification
{
    if ([VObjectManager sharedManager].mainUser)
    {
        [[VObjectManager sharedManager] isUser:[VObjectManager sharedManager].mainUser
                                     following:self.profile
                                  successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
         {
             VUserProfileHeaderView *header = self.profileHeaderView;
             header.editProfileButton.selected = [resultObjects[0] boolValue];
             header.user = header.user;
         }
                                     failBlock:nil];
    }
}

#pragma mark - Actions

#warning
//- (IBAction)refresh:(UIRefreshControl *)sender
//{
//    [self refreshWithCompletion:^(void)
//    {
//        if (self.streamDataSource.count)
//        {
//            [self animateHeaderShrinkingWithDuration:.5];
//        }
//    }];
//}

- (IBAction)composeMessage:(id)sender
{
    if (![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]]
                           animated:YES
                         completion:NULL];
        return;
    }

    VMessageContainerViewController    *composeController   = [VMessageContainerViewController messageViewControllerForUser:self.profile];
    
    if ([self.navigationController.viewControllers containsObject:composeController])
    {
        [self.navigationController popToViewController:composeController animated:YES];
    }
    else
    {
        [self.navigationController pushViewController:composeController animated:YES];
    }
}

- (void)editProfileHandler
{
    if (![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return;
    }
    
    if (self.isMe)
    {
        [self performSegueWithIdentifier:@"toEditProfile" sender:self];
    }
    else
    {
        VUserProfileHeaderView *header = self.profileHeaderView;
        [header.followButtonActivityIndicator startAnimating];
        
        VFailBlock fail = ^(NSOperation *operation, NSError *error)
        {
            header.editProfileButton.enabled = YES;
            [header.followButtonActivityIndicator stopAnimating];
            
            UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:nil
                                                                   message:NSLocalizedString(@"UnfollowError", @"")
                                                                  delegate:nil
                                                         cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                         otherButtonTitles:nil];
            [alert show];
        };
        VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *objects)
        {
            header.editProfileButton.enabled = YES;
            header.editProfileButton.selected = !header.editProfileButton.selected;
            [header.followButtonActivityIndicator stopAnimating];
            header.user = header.user;
        };
        
        if (header.editProfileButton.selected)
        {
            [[VObjectManager sharedManager] unfollowUser:self.profile
                                            successBlock:success
                                               failBlock:fail];
        }
        else
        {
            [[VObjectManager sharedManager] followUser:self.profile
                                          successBlock:success
                                             failBlock:fail];
        }
    }
}

#pragma mark - Navigation

- (void)followerHandler
{
    [self performSegueWithIdentifier:@"toFollowers" sender:self];
}

- (void)followingHandler
{
    [self performSegueWithIdentifier:@"toFollowing" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toEditProfile"])
    {
        VProfileEditViewController *controller = (VProfileEditViewController *)segue.destinationViewController;
        controller.profile = self.profile;
    }
    else if ([segue.identifier isEqualToString:@"toFollowers"])
    {
        VFollowerTableViewController   *controller = (VFollowerTableViewController *)segue.destinationViewController;
        controller.profile = self.profile;
    }
    else if ([segue.identifier isEqualToString:@"toFollowing"])
    {
        VFollowingTableViewController   *controller = (VFollowingTableViewController *)segue.destinationViewController;
        controller.profile = self.profile;
    }
}

#pragma mark - Animation

- (void)animateHeaderShrinkingWithDuration:(CGFloat)duration
{
    VUserProfileHeaderView *header = self.profileHeaderView;

    if (CGRectGetHeight(header.frame) != kVSmallUserHeaderHeight)
    {
        self.collectionView.contentOffset = CGPointMake(0, -CGRectGetHeight(self.view.bounds) - kVSmallUserHeaderHeight);
        header.frame = CGRectMake(0,
                                  -CGRectGetHeight(header.bounds) - kVSmallUserHeaderHeight,
                                  CGRectGetWidth(self.collectionView.bounds),
                                  CGRectGetHeight(header.bounds));
    }

    [UIView animateWithDuration:duration
                          delay:0.0f
         usingSpringWithDamping:0.95f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionAllowUserInteraction
                     animations:^
     {
         header.frame = CGRectMake(0,
                                   0,
                                   CGRectGetWidth(self.collectionView.bounds),
                                   kVSmallUserHeaderHeight);
         [header layoutIfNeeded];
         self.profileHeaderView = header;
         self.collectionView.contentOffset = CGPointMake(0,
                                                    - CGRectGetHeight(self.navigationController.navigationBar.bounds) -
                                                    CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]));
     } completion:^(BOOL finished)
    {
        if (duration == 0.0f)
        {
            // Forcing content offset to be neutral when not animating. Seemed like UITableViewController was setting contentoffset between the animation block and this completion.
            self.collectionView.contentOffset = CGPointMake(0, -[self.topLayoutGuide length]);
        }
     }];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context != VUserProfileViewContext)
    {
        return;
    }
    
    if (object == self.currentStream && [keyPath isEqualToString:NSStringFromSelector(@selector(streamItems))])
    {
        if (self.streamDataSource.count)
        {
            [self animateHeaderShrinkingWithDuration:.5];
        }
    }
    
    [self.currentStream removeObserver:self
                            forKeyPath:NSStringFromSelector(@selector(streamItems))];
}

@end
