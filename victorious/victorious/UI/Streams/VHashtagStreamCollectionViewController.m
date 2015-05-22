//
//  VHashtagStreamCollectionViewController.m
//  victorious
//
//  Created by Patrick Lynch on 2/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSString+VParseHelp.h"
#import "VHashtagStreamCollectionViewController.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "VObjectManager+Discover.h"
#import "VObjectManager+Login.h"
#import "VURLMacroReplacement.h"
#import "VUser.h"
#import "VHashtag.h"
#import "MBProgressHUD.h"
#import "VObjectManager+Sequence.h"
#import "VStream+Fetcher.h"
#import "VNoContentView.h"
#import "VAuthorizedAction.h"
#import <FBKVOController.h>
#import "VDependencyManager+VNavigationItem.h"
#import "VBarButton.h"

static NSString * const kHashtagStreamKey = @"hashtagStream";
static NSString * const kHashtagKey = @"hashtag";
static NSString * const kHashtagURLMacro = @"%%HASHTAG%%";

@interface VHashtagStreamCollectionViewController () <VAccessoryNavigationSource>

@property (nonatomic, assign, getter=isFollowingSelectedHashtag) BOOL followingSelectedHashtag;
@property (nonatomic, strong) NSString *selectedHashtag;
@property (nonatomic, weak) MBProgressHUD *failureHUD;
@property (nonatomic, readonly) UIBarButtonItem *followBarButton;
@property (nonatomic, assign, getter=isFollowingEnabled) BOOL followingEnabled;

@end

@implementation VHashtagStreamCollectionViewController

#pragma mark - Instantiation

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    
    NSAssert([NSThread isMainThread], @"This method needs to be called on the main thread");
    NSString *hashtag = [dependencyManager stringForKey:kHashtagKey];
    NSString *streamURL = [dependencyManager stringForKey:VStreamCollectionViewControllerStreamURLKey];
    
    if ( hashtag != nil )
    {
        VURLMacroReplacement *macroReplacement = [[VURLMacroReplacement alloc] init];
        streamURL = [macroReplacement urlByPartiallyReplacingMacrosFromDictionary:@{ kHashtagURLMacro: hashtag } inURLString:streamURL];
    }
    
    VStream *stream = [VStream streamForPath:[streamURL v_pathComponent] inContext:[[VObjectManager sharedManager].managedObjectStore mainQueueManagedObjectContext]];
    stream.hashtag = hashtag;
    stream.name = [NSString stringWithFormat:@"#%@", hashtag];
    
    VHashtagStreamCollectionViewController *streamCollection = [[self class] streamViewControllerForStream:stream];
    streamCollection.selectedHashtag = hashtag;
    streamCollection.dependencyManager = dependencyManager;
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
    
    self.followingEnabled = NO;
    
    [self.KVOController observe:[[VObjectManager sharedManager] mainUser]
                        keyPath:NSStringFromSelector(@selector(hashtags))
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                         action:@selector(hashtagsUpdated)];
    
    if ( [VObjectManager sharedManager].mainUser.hashtags.count == 0 )
    {
        //Only fetch hashtags for user to update the follow button status and visibility if they've never been loaded before
        [self fetchHashtagsForLoggedInUser];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUserFollowingStatus];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Must also call here since navigation items are set after viewDidAppear:
    [self updateUserFollowingStatus];
}

- (void)hashtagsUpdated
{
    [self updateUserFollowingStatus];
}

- (void)updateNavigationItems
{
    [self.dependencyManager configureNavigationItem:self.navigationItem forViewController:self];
}

#pragma mark - Fetch Users Tags

- (void)fetchHashtagsForLoggedInUser
{
    VSuccessBlock successBlock = ^(NSOperation *operation, id result, NSArray *resultObjects)
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
    if ( self.streamDataSource.count == 0 && !self.streamDataSource.hasHeaderCell )
    {
        if ( self.noContentView == nil )
        {
            VNoContentView *noContentView = [VNoContentView noContentViewWithFrame:self.collectionView.frame];
            if ( [noContentView respondsToSelector:@selector(setDependencyManager:)] )
            {
                noContentView.dependencyManager = self.dependencyManager;
            }
            noContentView.title = NSLocalizedString( @"NoHashtagsTitle", @"" );
            noContentView.message = [NSString stringWithFormat:NSLocalizedString( @"NoHashtagsMessage", @"" ), self.selectedHashtag];
            noContentView.icon = [UIImage imageNamed:@"tabIconHashtag"];
            self.noContentView = noContentView;
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
    VAuthorizedAction *authorization = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                      dependencyManager:self.dependencyManager];
    [authorization performFromViewController:self context:VAuthorizationContextFollowHashtag completion:^(BOOL authorized)
     {
         if (!authorized)
         {
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
     }];
}

- (void)followHashtag
{
    self.followingEnabled = NO;
    
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        // Animate follow button
        self.followingSelectedHashtag = YES;
        
        self.followingEnabled = YES;
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        self.failureHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.failureHUD.mode = MBProgressHUDModeText;
        self.failureHUD.detailsLabelText = NSLocalizedString(@"HashtagSubscribeError", @"");
        [self.failureHUD hide:YES afterDelay:3.0f];
        
        self.followingEnabled = YES;
    };
    
    // Backend Subscribe to Hashtag call
    [[VObjectManager sharedManager] subscribeToHashtag:self.selectedHashtag
                                          successBlock:successBlock
                                             failBlock:failureBlock];
}

- (void)unfollowHashtag
{
    self.followingEnabled = NO;
    
    VSuccessBlock successBlock = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        self.followingSelectedHashtag = NO;
        
        self.followingEnabled = YES;
    };
    
    VFailBlock failureBlock = ^(NSOperation *operation, NSError *error)
    {
        self.failureHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.failureHUD.mode = MBProgressHUDModeText;
        self.failureHUD.detailsLabelText = NSLocalizedString(@"HashtagUnsubscribeError", @"");
        [self.failureHUD hide:YES afterDelay:3.0f];
        
        self.followingEnabled = YES;
    };
    
    // Backend Unsubscribe to Hashtag call
    [[VObjectManager sharedManager] unsubscribeToHashtag:self.selectedHashtag
                                            successBlock:successBlock
                                               failBlock:failureBlock];
}

#pragma mark - UIBarButtonItem state management

- (void)setFollowingSelectedHashtag:(BOOL)followingSelectedHashtag
{
    _followingSelectedHashtag = followingSelectedHashtag;
    
    [self updateFollowingStatus];
}

- (VBarButton *)followBarButton
{
    return [self.dependencyManager barButtonFromNavigationItem:self.navigationItem
                                                 forIdentifier:VDependencyManagerAccessoryItemFollowHashtag];
}

- (void)updateFollowingStatus
{
    VNavigationMenuItem *menuItem = [self.dependencyManager menuItemWithIdentifier:VDependencyManagerAccessoryItemFollowHashtag];
    
    if ( self.streamDataSource.count == 0 || menuItem == nil )
    {
        self.followingEnabled = NO;
    }
    else
    {
        self.followingEnabled = YES;
        if ( self.isFollowingSelectedHashtag )
        {
            [self.followBarButton setImage:menuItem.selectedIcon];
        }
        else
        {
            [self.followBarButton setImage:menuItem.icon];
        }
    }
}

- (void)setFollowingEnabled:(BOOL)followingEnabled
{
    _followingEnabled = followingEnabled;
    self.followBarButton.enabled = followingEnabled;
}

#pragma mark - VAccessoryNavigationSource

- (BOOL)shouldNavigateWithAccessoryMenuItem:(VNavigationMenuItem *)menuItem
{
    if ( [menuItem.identifier isEqualToString:VDependencyManagerAccessoryItemFollowHashtag] )
    {
        [self toggleFollowHashtag];
        return NO;
    }
    return YES;
}

- (BOOL)shouldDisplayAccessoryMenuItem:(VNavigationMenuItem *)menuItem fromSource:(UIViewController *)source
{
    // Becase the backend doesn't assign text posts to hashtags based on tags in the text,
    // Text posts will allow you to view a hastag stream for hashtag that doesn't exist.
    // If you're viewing a hashtag stream with no items, the backend returns an error if you
    // attempt to follow it. This prevents showing the button in that case.
    return self.streamDataSource.count > 0;
}

- (BOOL)menuItem:(VNavigationMenuItem *)menuItem requiresAuthorizationWithContext:(VAuthorizationContext *)context
{
    if ( [menuItem.identifier isEqualToString:VDependencyManagerAccessoryItemFollowHashtag] )
    {
        *context = VAuthorizationContextFollowHashtag;
        return YES;
    }
    return NO;
}

@end

#pragma mark -

@implementation VDependencyManager (VHashtagStreamCollectionViewController)

- (VHashtagStreamCollectionViewController *)hashtagStreamWithHashtag:(NSString *)hashtag
{
    NSParameterAssert(hashtag != nil );
    return [self templateValueOfType:[VHashtagStreamCollectionViewController class] forKey:kHashtagStreamKey withAddedDependencies:@{ kHashtagKey: hashtag }];
}

@end