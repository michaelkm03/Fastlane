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
#import "VUser.h"
#import "VHashtag.h"
#import "MBProgressHUD.h"
#import "VStream+Fetcher.h"
#import "VNoContentView.h"
#import "VDependencyManager+VAccessoryScreens.h"
#import "VDependencyManager+VNavigationItem.h"
#import "VBarButton.h"
#import "VFollowControl.h"
#import "UIViewController+VAccessoryScreens.h"
#import "VDependencyManager+VTabScaffoldViewController.h"
#import "VHashtag+RestKit.h"
#import "victorious-Swift.h"

@import VictoriousIOSSDK;
@import KVOController;

static NSString * const kHashtagStreamKey = @"hashtagStream";
static NSString * const kHashtagKey = @"hashtag";
static NSString * const kHashtagURLMacro = @"%%HASHTAG%%";

@interface VHashtagStreamCollectionViewController () <VAccessoryNavigationSource>

@property (nonatomic, assign, getter=isFollowingSelectedHashtag) BOOL followingSelectedHashtag;
@property (nonatomic, strong) NSString *selectedHashtag;
@property (nonatomic, weak) MBProgressHUD *failureHUD;
@property (nonatomic, assign, getter=isFollowingEnabled) BOOL followingEnabled;

@property (nonatomic, strong) VFollowControl *followControl;

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
        VSDKURLMacroReplacement *macroReplacement = [[VSDKURLMacroReplacement alloc] init];
        streamURL = [macroReplacement urlByPartiallyReplacingMacrosFromDictionary:@{ kHashtagURLMacro: hashtag } inURLString:streamURL];
    }
    
    NSString *apiPath = [streamURL v_pathComponent];
    NSDictionary *query = @{ @"apiPath" : apiPath };
    
    __block VStream *stream = nil;
    id<PersistentStoreType> persistentStore = [PersistentStoreSelector defaultPersistentStore];
    [persistentStore.mainContext performBlockAndWait:^void {
        stream = (VStream *)[persistentStore.mainContext v_findOrCreateObjectWithEntityName:[VStream entityName] queryDictionary:query];
        stream.name = [dependencyManager stringForKey:VDependencyManagerTitleKey];
        stream.name = [NSString stringWithFormat:@"#%@", hashtag];
        [persistentStore.mainContext save:nil];
    }];
    
    VHashtagStreamCollectionViewController *streamCollection = [[self class] streamViewControllerForStream:stream];
    streamCollection.selectedHashtag = hashtag;
    streamCollection.dependencyManager = dependencyManager;
    
    streamCollection.followControl = [[VFollowControl alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    streamCollection.followControl.dependencyManager = dependencyManager;
    streamCollection.followControl.tintUnselectedImage = YES;
    streamCollection.followControl.unselectedTintColor = [dependencyManager barItemTintColor];
    
    if ([AgeGate isAnonymousUser])
    {
        [streamCollection.followControl removeFromSuperview];
        streamCollection.followControl = nil;
    }
    
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
    
    [self.KVOController observe:[VCurrentUser user]
                        keyPath:NSStringFromSelector(@selector(followedHashtags))
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                         action:@selector(hashtagsUpdated)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.dependencyManager configureNavigationItem:self.navigationItem];
    [self updateUserFollowingStatus];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Must also call here since navigation items are set after viewDidAppear:
    [self updateUserFollowingStatus];
    
    [self v_addBadgingToAccessoryScreensWithDependencyManager:self.dependencyManager];
}

- (void)hashtagsUpdated
{
    [self updateUserFollowingStatus];
}

- (void)updateNavigationItems
{
    if ( self.navigationItem.rightBarButtonItem == nil )
    {
        [self v_addAccessoryScreensWithDependencyManager:self.dependencyManager];
        [self updateFollowStatusAnimated:NO];
    }
}

// This is an override of a superclass method
- (void)didFinishLoadingWithPageType:(VPageType)pageType
{
    [self dataSourceDidRefresh];
    [self updateNavigationItems];
    [self updateUserFollowingStatus];
}

- (void)updateUserFollowingStatus
{
    NSAssert( self.selectedHashtag != nil, @"To present this view controller, there must be a selected hashtag." );
    NSAssert( self.selectedHashtag.length > 0, @"To present this view controller, there must be a selected hashtag." );
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hashtag.tag == %@", self.selectedHashtag.lowercaseString];
    VFollowedHashtag *followedHashtag = [[VCurrentUser user].followedHashtags filteredOrderedSetUsingPredicate:predicate].firstObject;
    BOOL followingHashtag = followedHashtag != nil;
    if ( followingHashtag != self.followingSelectedHashtag)
    {
        self.followingSelectedHashtag = followingHashtag;
        [self updateFollowStatusAnimated:YES];
    }
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
    if ( self.isFollowingSelectedHashtag )
    {
        RequestOperation *operation = [[UnfollowHashtagOperation alloc] initWithHashtag:self.selectedHashtag];
        [operation queueOn:[RequestOperation sharedQueue] completionBlock:^(NSError *_Nullable error)
    {
            self.followingEnabled = YES;
            self.followingSelectedHashtag = NO;
            [self updateFollowStatusAnimated:YES];
        }];
    }
    else
    {
        RequestOperation *operation = [[FollowHashtagOperation alloc] initWithHashtag:self.selectedHashtag];
        [operation queueOn:[RequestOperation sharedQueue] completionBlock:^(NSError *_Nullable error)
    {
            self.followingEnabled = YES;
            self.followingSelectedHashtag = YES;
            [self updateFollowStatusAnimated:YES];
        }];
    }
}

#pragma mark - UIBarButtonItem state management

- (void)updateFollowStatusAnimated:(BOOL)animated
{
    if ( self.streamDataSource.count == 0 )
    {
        self.followingEnabled = NO;
    }
    
    //If we get into a weird state and the relaionships are the same don't do anything
    
    if (self.followControl.controlState == [VFollowControl controlStateForFollowing:self.isFollowingSelectedHashtag])
    {
        return;
    }

    [self.followControl setControlState:[VFollowControl controlStateForFollowing:self.isFollowingSelectedHashtag]
                               animated:animated];
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

- (UIControl *)customControlForAccessoryMenuItem:(VNavigationMenuItem *)menuItem
{
    return self.followControl;
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
