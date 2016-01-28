//
//  VLikedContentStreamCollectionViewController.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLikedContentStreamCollectionViewController.h"
#import "VNoContentView.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "VDependencyManager+VNavigationMenuItem.h"
#import "victorious-Swift.h"
#import "NSArray+VMap.h"

static NSString * const kNoLikedContentTitleKey = @"noContentTitle";
static NSString * const kNoLikedContentSubtitleKey = @"noContentSubtitle";
static NSString * const kNoLikedContentIconKey = @"noContentIcon";

static NSString * const kLogInChangedNotification = @"com.getvictorious.LoggedInChangedNotification";

@interface VLikedContentStreamCollectionViewController ()

@property (nonatomic, assign) BOOL shouldRefreshOnView;
@property (nonatomic, strong) NSMutableArray *streamItemsToRemove;

@end

@implementation VLikedContentStreamCollectionViewController

#pragma mark - Factory methods

+ (instancetype)streamViewControllerForStream:(VStream *)stream
{
    NSString *identifier = NSStringFromClass([VLikedContentStreamCollectionViewController class]);
    VLikedContentStreamCollectionViewController *streamCollection = (VLikedContentStreamCollectionViewController *)[[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:identifier];
    streamCollection.currentStream = stream;
    return streamCollection;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shouldRefreshOnView = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStatusDidChange:)
                                                 name:kLogInChangedNotification
                                               object:nil];
    
    self.noContentView.title = [self.dependencyManager stringForKey:kNoLikedContentTitleKey];
    self.noContentView.message = [self.dependencyManager stringForKey:kNoLikedContentSubtitleKey];
    self.noContentView.icon = [self.dependencyManager imageForKey:kNoLikedContentIconKey];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSArray<NSString *> *streamItemIDs = [self.streamItemsToRemove v_map:^NSString *(VStreamItem *streamItem) {
        return streamItem.remoteId;
    }];
    Operation *operation = [[RemoveStreamItemOperation alloc] initWithStreamItemIDs:streamItemIDs];
    [operation queueOn:operation.defaultQueue completionBlock:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( self.shouldRefreshOnView )
    {
        [self.refreshControl beginRefreshing];
        [self loadPage:VPageTypeFirst completion:nil];
        self.shouldRefreshOnView = NO;
    }
}

- (NSMutableArray *)streamItemsToRemove
{
    if (_streamItemsToRemove == nil)
    {
        _streamItemsToRemove = [NSMutableArray new];
    }
    
    return _streamItemsToRemove;
}

- (void)loginStatusDidChange:(NSNotification *)notification
{
    [self.streamDataSource.paginatedDataSource unload];
    self.shouldRefreshOnView = YES;
}

- (void)willLikeSequence:(VSequence *)sequence withView:(UIView *)view completion:(void(^)(BOOL success))completion
{
    __weak typeof(self) welf = self;
    [super willLikeSequence:sequence withView:view completion:^(BOOL success)
    {
        __strong typeof(self) strongSelf = welf;
        NSIndexPath *likedIndexPath = [strongSelf.streamDataSource indexPathForItem:sequence];
        
        if (likedIndexPath != nil && success)
        {
            // Save cell index path for removal
            if (!sequence.isLikedByMainUser.boolValue)
            {
                [strongSelf.streamItemsToRemove addObject:sequence];
            }
            else if ([strongSelf.streamItemsToRemove containsObject:sequence])
            {
                [strongSelf.streamItemsToRemove removeObject:sequence];
            }
        }
        
        if (completion != nil)
        {
            completion(success);
        }
    }];
}

#pragma mark - Accessory items

- (BOOL)shouldDisplayAccessoryMenuItem:(VNavigationMenuItem *)menuItem fromSource:(UIViewController *)source
{
    // Make sure only accessory screen items for THIS view controller are shown
    NSArray *localAccessoryItems = [self.dependencyManager accessoryMenuItemsWithInheritance:NO];
    if (![localAccessoryItems containsObject:menuItem])
    {
        return NO;
    }
    
    return YES;
}

@end
