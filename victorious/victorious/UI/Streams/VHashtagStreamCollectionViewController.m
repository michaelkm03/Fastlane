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
#import "MBProgressHUD.h"
#import "VStreamItem+Fetcher.h"
#import "VNoContentView.h"
#import "VDependencyManager+VAccessoryScreens.h"
#import "VDependencyManager+VNavigationItem.h"
#import "VBarButton.h"
#import "VFollowControl.h"
#import "UIViewController+VAccessoryScreens.h"
#import "VDependencyManager+NavigationBar.h"
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
        stream = (VStream *)[persistentStore.mainContext v_findOrCreateObjectWithEntityName:[VStream v_entityName] queryDictionary:query];
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
    
    VNoContentView *noContentView = [VNoContentView viewFromNibWithFrame:streamCollection.view.bounds];
    noContentView.title = NSLocalizedString( @"NoHashtagsTitle", @"" );
    noContentView.dependencyManager = dependencyManager;
    noContentView.message = [NSString stringWithFormat:NSLocalizedString( @"NoHashtagsMessage", @"" ), hashtag];
    noContentView.icon = [UIImage imageNamed:@"tabIconHashtag"];
    streamCollection.noContentView = noContentView;
    
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

- (void)hashtagsUpdated
{
    [self updateUserFollowingStatus];
}

- (void)updateNavigationItems
{
    if ( self.navigationItem.rightBarButtonItem == nil )
    {
        if ( self.streamDataSource.count > 0 )
        {
            [self v_addAccessoryScreensWithDependencyManager:self.dependencyManager];
        }
    }
    [self updateFollowStatusAnimated:NO];
}

- (void)updateUserFollowingStatus
{
    NSAssert( self.selectedHashtag != nil, @"To present this view controller, there must be a selected hashtag." );
    NSAssert( self.selectedHashtag.length > 0, @"To present this view controller, there must be a selected hashtag." );
    
    BOOL followingHashtag = [[VCurrentUser user] isFollowingHashtagString:self.selectedHashtag];
    if ( followingHashtag != self.followingSelectedHashtag)
    {
        self.followingSelectedHashtag = followingHashtag;
        [self updateFollowStatusAnimated:YES];
    }
}

#pragma mark - Follow / Unfollow actions

- (void)toggleFollowHashtag
{
    FetcherOperation *operation = [[FollowHashtagToggleOperation alloc] initWithHashtag:self.selectedHashtag];
    [operation queueWithCompletion:^(NSArray *_Nullable results, NSError *_Nullable error, BOOL cancelled)
     {
         self.followingEnabled = YES;
     }];
}

#pragma mark - UIBarButtonItem state management

- (void)updateFollowStatusAnimated:(BOOL)animated
{
    if ( self.streamDataSource.count == 0 )
    {
        self.followingEnabled = NO;
    }

    VFollowControlState controlState = [VFollowControl controlStateForFollowing:self.isFollowingSelectedHashtag];
    [self.followControl setControlState:controlState animated:animated];
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
    return YES;
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

- (void)paginatedDataSource:(PaginatedDataSource *)paginatedDataSource didUpdateVisibleItemsFrom:(NSOrderedSet *)oldValue to:(NSOrderedSet *)newValue
{
    [super paginatedDataSource:paginatedDataSource didUpdateVisibleItemsFrom:oldValue to:newValue];
    [self updateNavigationItems];
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
