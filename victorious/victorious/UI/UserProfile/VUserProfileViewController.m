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

#import "VInboxContainerViewController.h"

#import "VUserProfileHeaderView.h"

const   CGFloat kVNavigationBarHeight = 44.0;
const   CGFloat kVLargeBottomBuffer = 193;
const   CGFloat kVSmallBottomBuffer = 25;
const   CGFloat kVSmallUserHeaderHeight = 316;

@interface VUserProfileViewController () <VUserProfileHeaderDelegate>

@property   (nonatomic, strong) VUser*                  profile;

@property (nonatomic, strong) UIImageView*              backgroundImageView;
@property   (nonatomic) BOOL                            isMe;

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
    self.isMe = (self.profile.remoteId.integerValue == [VObjectManager sharedManager].mainUser.remoteId.integerValue);
    
    if (self.isMe)
        self.navigationItem.title = NSLocalizedString(@"me", "");
    else
        self.navigationItem.title = self.profile.name ? [@"@" stringByAppendingString:self.profile.name] : @"Profile";
    
    [super viewDidLoad];
   
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    VUserProfileHeaderView* headerView =  [VUserProfileHeaderView newViewWithFrame:CGRectMake(0, 0, screenWidth,
                                                                                              screenHeight - kVNavigationBarHeight)];
    headerView.user = self.profile;
    headerView.delegate = self;
    self.tableView.tableHeaderView = headerView;
    
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
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.backgroundImageView setBlurredImageWithURL:[NSURL URLWithString:self.profile.pictureUrl]
                           placeholderImage:defaultBackgroundImage
                                  tintColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    self.tableView.backgroundView = self.backgroundImageView;
    
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
    self.currentFilter = [[VObjectManager sharedManager] sequenceFilterForUser:self.profile];
    if ([self isViewLoaded])
    {
        [self refresh:nil];
    }
}

#pragma mark - Support

- (void)setHeaderBuffer:(CGFloat)buffer
{
    VUserProfileHeaderView* header = (VUserProfileHeaderView*)self.tableView.tableHeaderView;
    
    CGFloat bufferDiff = buffer - header.bottomBufferConstraint.constant;
    CGPoint newOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y - bufferDiff);
    self.tableView.contentOffset = newOffset;
    
    header.bottomBufferConstraint.constant = buffer;
    [self.tableView layoutIfNeeded];
}

- (void)setHeaderHeight:(CGFloat)height
{
    VUserProfileHeaderView* header = (VUserProfileHeaderView*)self.tableView.tableHeaderView;
    
    CGFloat heightDiff = header.frame.size.height - height;
    
    CGRect frame = header.frame;
    frame.size.height = height;
    header.frame = frame;
    self.tableView.tableHeaderView = header;
    
    CGPoint newOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y - heightDiff);
    self.tableView.contentOffset = newOffset;
}

- (void)loginStateDidChange:(NSNotification *)notification
{
    if ([VObjectManager sharedManager].mainUser)
    {
        [[VObjectManager sharedManager] isUser:[VObjectManager sharedManager].mainUser
                                     following:self.profile
                                  successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
         {
             VUserProfileHeaderView* header = (VUserProfileHeaderView*)self.tableView.tableHeaderView;

             if ([resultObjects[0] boolValue])
                 header.editProfileButton.selected = YES;
             header.user = header.user;
         }
                                     failBlock:nil];
    }
}

#pragma mark - Actions

- (IBAction)refresh:(UIRefreshControl *)sender
{
    [self refreshWithCompletion:^(void)
    {
        if (self.tableDataSource.count)
        {
            [UIView animateWithDuration:0.5 animations:^(void)
            {
                [self setHeaderBuffer:kVSmallBottomBuffer];
            }
             completion:^(BOOL finished)
            {
                [self setHeaderHeight:kVSmallUserHeaderHeight];
            }];
        }
        else
        {
            [UIView animateWithDuration:0.5 animations:^(void)
             {
                 [self setHeaderBuffer:kVLargeBottomBuffer];
             }
                             completion:^(BOOL finished)
             {
                 [self setHeaderHeight:[UIScreen mainScreen].bounds.size.height];
             }];
        }
    }];
}

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

- (void)editProfileHandler
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    if (self.isMe)
        [self performSegueWithIdentifier:@"toEditProfile" sender:self];
    
    else
    {
        VUserProfileHeaderView* header = (VUserProfileHeaderView*)self.tableView.tableHeaderView;
        [header.followButtonActivityIndicator startAnimating];
        
        if (header.editProfileButton.selected)
        {
            [[VObjectManager sharedManager] unfollowUser:self.profile
                                            successBlock:^(NSOperation *operation, id fullResponse, NSArray *objects)
             {
                 header.editProfileButton.enabled = YES;
                 header.editProfileButton.selected = NO;
                 [header.followButtonActivityIndicator stopAnimating];
                 header.user = header.user;
             }
                                               failBlock:^(NSOperation *operation, NSError *error)
             {
                 header.editProfileButton.enabled = YES;
                 [header.followButtonActivityIndicator stopAnimating];
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
                 header.editProfileButton.enabled = YES;
                 header.editProfileButton.selected = YES;
                 [header.followButtonActivityIndicator stopAnimating];
                  header.user = header.user;
             }
                                             failBlock:^(NSOperation *operation, NSError *error)
             {
                 header.editProfileButton.enabled = YES;
                 [header.followButtonActivityIndicator stopAnimating];
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                 message:NSLocalizedString(@"FollowError", @"")
                                                                delegate:nil
                                                       cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                       otherButtonTitles:nil];
                 [alert show];
             }];
        }
    }
}

- (void)followerHandler
{
    [self performSegueWithIdentifier:@"toFollowers" sender:self];
}

- (void)followingHandler
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

@end
