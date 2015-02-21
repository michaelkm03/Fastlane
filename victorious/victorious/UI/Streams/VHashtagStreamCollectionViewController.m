//
//  VHashtagStreamCollectionViewController.m
//  victorious
//
//  Created by Patrick Lynch on 2/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHashtagStreamCollectionViewController.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "VObjectManager+Discover.h"
#import "VObjectManager+Login.h"
#import "VUser.h"
#import "VHashtag.h"
#import "VAuthorizationViewControllerFactory.h"
#import "MBProgressHUD.h"
#import "VObjectManager+Sequence.h"
#import "VStream+Fetcher.h"
#import "VNoContentView.h"

@interface VHashtagStreamCollectionViewController ()

@property (nonatomic, assign, getter=isFollowingSelectedHashtag) BOOL followingSelectedHashtag;
@property (nonatomic, strong) NSString *selectedHashtag;
@property (nonatomic, weak) MBProgressHUD *failureHUD;

@property (nonatomic, strong) VNoContentView *noContentView;

@end

@implementation VHashtagStreamCollectionViewController

#pragma mark - Instantiation

+ (instancetype)instantiateWithHashtag:(NSString *)hashtag
{
    VHashtagStreamCollectionViewController *streamCollection = [[self class] streamViewControllerForStream:[VStream streamForHashTag:hashtag]];
    streamCollection.selectedHashtag = hashtag;
    return streamCollection;
}

+ (instancetype)streamViewControllerForStream:(VStream *)stream
{
    NSString *identifier = NSStringFromClass([VHashtagStreamCollectionViewController class]);
    VHashtagStreamCollectionViewController *streamCollection = (VHashtagStreamCollectionViewController *)[[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:identifier];
    streamCollection.currentStream = stream;
    return streamCollection;
}

#pragma mark - View controller life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self fetchHashtagsForLoggedInUser];
}

#pragma mark - Tracking

// This method is called by super class
- (void)trackStreamDidAppear
{
    NSDictionary *params = @{ VTrackingKeyHashtag : self.selectedHashtag ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidViewHashtagStream parameters:params];
}

#pragma mark - Fetch Users Tags

- (void)fetchHashtagsForLoggedInUser
{
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        [self updateUserFollowingStatus];
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        VLog(@"%@\n%@", operation, error);
    };
    
    [[VObjectManager sharedManager] getHashtagsSubscribedToWithPageType:VPageTypeFirst
                                                           perPageLimit:1000
                                                           successBlock:successBlock
                                                              failBlock:failureBlock];
}

- (void)refreshWithCompletion:(void (^)(void))completionBlock
{
    [super refreshWithCompletion:^
     {
         [self updateUserFollowingStatus];
         [self dataSourceDidRefresh];
     }];
}

- (void)updateUserFollowingStatus
{
    NSAssert( self.selectedHashtag != nil, @"To present this view controller, there must be a selected hashtag." );
    NSAssert( self.selectedHashtag.length > 0, @"To present this view controller, there must be a selected hashtag." );
    
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tag == %@", self.selectedHashtag.lowercaseString];
    VHashtag *hashtag = [mainUser.hashtags filteredOrderedSetUsingPredicate:predicate].firstObject;
    self.followingSelectedHashtag = hashtag != nil;
}

- (void)dataSourceDidRefresh
{
    if ( self.streamDataSource.count == 0 )
    {
        if ( self.noContentView == nil )
        {
            self.noContentView = [VNoContentView noContentViewWithFrame:self.collectionView.frame];
            self.noContentView.titleLabel.text = NSLocalizedString( @"NoHashtagsTitle", @"" );
            self.noContentView.messageLabel.text = [NSString stringWithFormat:NSLocalizedString( @"NoHashtagsMessage", @"" ), self.selectedHashtag];
            self.noContentView.iconImageView.image = [UIImage imageNamed:@"tabIconHashtag"];
        }
        
        self.collectionView.backgroundView = self.noContentView;
    }
    else
    {
        self.collectionView.backgroundView = nil;
    }
}

#pragma mark - Follow / Unfollow actions

- (void)toggleFollowHashtag
{
    // Check if logged in before attempting to subscribe / unsubscribe
    if (![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return;
    }
    
    if ( self.isFollowingSelectedHashtag )
    {
        [self unfollowHashtag];
    }
    else
    {
        [self followHashtag];
    }
}

- (void)followHashtag
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        // Animate follow button
        self.followingSelectedHashtag = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kHashtagStatusChangedNotification object:nil];
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        self.failureHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.failureHUD.mode = MBProgressHUDModeText;
        self.failureHUD.detailsLabelText = NSLocalizedString(@"HashtagSubscribeError", @"");
        [self.failureHUD hide:YES afterDelay:3.0f];
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
    };
    
    // Backend Subscribe to Hashtag call
    [[VObjectManager sharedManager] subscribeToHashtag:self.selectedHashtag
                                          successBlock:successBlock
                                             failBlock:failureBlock];
}

- (void)unfollowHashtag
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        self.followingSelectedHashtag = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kHashtagStatusChangedNotification object:nil];
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        self.failureHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.failureHUD.mode = MBProgressHUDModeText;
        self.failureHUD.detailsLabelText = NSLocalizedString(@"HashtagUnsubscribeError", @"");
        [self.failureHUD hide:YES afterDelay:3.0f];
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
    };
    
    // Backend Unsubscribe to Hashtag call
    [[VObjectManager sharedManager] unsubscribeToHashtag:self.selectedHashtag
                                            successBlock:successBlock
                                               failBlock:failureBlock];
}

#pragma mark - UIBarButtonItem state management

- (void)setFollowingSelectedHashtag:(BOOL)followingSelectedHashtag
{
    BOOL isAlreadyNewValue = _followingSelectedHashtag == followingSelectedHashtag;
    
    _followingSelectedHashtag = followingSelectedHashtag;
    
    [self updateFollowingStatusAnimated:!isAlreadyNewValue];
}

- (UIImage *)followButtonImage
{
    NSString *imageName = self.isFollowingSelectedHashtag ? @"followedHashtag" : @"streamFollowHashtag";
    return [UIImage imageNamed:imageName];
}

- (void)updateFollowingStatusAnimated:(BOOL)animated
{
    if ( self.streamDataSource.count == 0 )
    {
        self.navigationItem.rightBarButtonItem = nil;
        return;
    }
    
    // Reset the hashtag button image
    UIImage *hashtagButtonImage = [[self followButtonImage] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:hashtagButtonImage
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(toggleFollowHashtag)];
}

@end
