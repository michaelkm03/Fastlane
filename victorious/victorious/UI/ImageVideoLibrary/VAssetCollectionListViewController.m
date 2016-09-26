//
//  VAssetCollectionListViewController.m
//  victorious
//
//  Created by Michael Sena on 6/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAssetCollectionListViewController.h"
#import "VPermissionPhotoLibrary.h"
#import "VAssetGroupTableViewCell.h"
#import "VCollectionListPresentationController.h"
#import "VScaleAnimator.h"
#import "victorious-swift.h"

@import Photos;

// Cell is registered with this key in the storyboard
static NSString * const kAlbumCellReuseIdentifier = @"albumCell";

@interface VAssetCollectionListViewController () <UITableViewDataSource, UITableViewDelegate, PHPhotoLibraryChangeObserver, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *contentContainer;

@property (nonatomic, assign) PHAssetMediaType mediaType;

@property (nonatomic, strong) VPermissionPhotoLibrary *libraryPermissions;
@property (nonatomic, assign) BOOL needsFetch;

@property (nonatomic, strong) NSMutableSet *fetchResults;
@property (nonatomic, strong) NSArray *collections;
@property (nonatomic, strong) NSArray *assetFetchResultForCollections;

@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

// Only fetch every 30 seconds.
@property (nonatomic, strong) NSDate *lastFetch;
@property (nonatomic, strong) dispatch_queue_t serialFetchQueue;

@property (nonatomic, strong) VScaleAnimator *animator;

@end

@implementation VAssetCollectionListViewController

#pragma mark - Lifecycle

+ (instancetype)assetCollectionListViewControllerWithMediaType:(PHAssetMediaType)mediaType
{
    NSBundle *bundleForClass = [NSBundle bundleForClass:self];
    UIStoryboard *storyboardForClass = [UIStoryboard storyboardWithName:NSStringFromClass(self)
                                                                 bundle:bundleForClass];
    VAssetCollectionListViewController *listViewController = [storyboardForClass instantiateInitialViewController];
    listViewController.transitioningDelegate = listViewController;
    listViewController.modalPresentationStyle = UIModalPresentationCustom;
    if ( mediaType != PHAssetMediaTypeAudio )
    {
        listViewController.mediaType = mediaType;
    }
    else
    {
        NSAssert(false, @"Unsupported media type!");
    }
    return listViewController;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        _serialFetchQueue = dispatch_queue_create("com.victorious.photosCollectionsFetchQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.fetchResults = [[NSMutableSet alloc] init];
    self.numberFormatter = [self createNumberFormatter];

    self.libraryPermissions = [[VPermissionPhotoLibrary alloc] init];
    
    self.animator = [[VScaleAnimator alloc] init];
    
    // Fetch once on awakeFromNib
    if ([self.libraryPermissions permissionState] == VPermissionStateAuthorized)
    {
        self.needsFetch = NO;
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
}

#pragma mark - UIViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.contentContainer.layer.cornerRadius = 5.0f;
    self.contentContainer.layer.masksToBounds = YES;
    
    for (NSIndexPath *selectedIndexPath in self.tableView.indexPathsForSelectedRows)
    {
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:NO];
    }
    
    if (([self.libraryPermissions permissionState] == VPermissionStateAuthorized) && self.needsFetch)
    {
        self.needsFetch = NO;
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView flashScrollIndicators];
}

#pragma mark - Target/Action

- (IBAction)tappedAway:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.libraryPermissions permissionState] == VPermissionStateAuthorized)
    {
        return self.collections.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VAssetGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAlbumCellReuseIdentifier
                                                            forIndexPath:indexPath];
    // Set the localized title on the cell
    PHAssetCollection *collection = self.collections[indexPath.row];
    cell.groupTitleLabel.text = collection.localizedTitle;

    PHFetchResult *fetchResultForCollection = self.assetFetchResultForCollections[indexPath.row];
    [self.fetchResults addObject:fetchResultForCollection];
    
    // Set the count on the subtitle label
    cell.groupSubtitleLabel.text = [self.numberFormatter stringFromNumber:@(fetchResultForCollection.count)];
    
    // Use the first asset as a thumbnail
    cell.asset = [fetchResultForCollection firstObject];

    return cell;
}

#pragma mark - Table View Delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView.indexPathsForSelectedRows containsObject:indexPath])
    {
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PHAssetCollection *collectionForIndexPath = self.collections[indexPath.row];
    
    if (self.collectionSelectionHandler != nil)
    {
        self.collectionSelectionHandler(collectionForIndexPath);
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        BOOL dirty = NO;
        for (PHFetchResult *fetchResult in self.fetchResults)
        {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:fetchResult];
            if (![changeDetails hasIncrementalChanges])
            {
                dirty = YES;
                break;
            }
        }
        
        if (dirty)
        {
            [self fetchCollectionsWithCompletion:^
             {
                 [self.tableView reloadData];
             }];
        }
    });
}

#pragma mark - Fetching

- (void)fetchDefaultCollectionWithCompletion:(void (^)(PHAssetCollection *collection))completion
{
    NSParameterAssert(completion != nil);
    __weak typeof(self) welf = self;
    [self fetchCollectionsWithCompletion:^
    {
        __strong typeof(welf) strongSelf = welf;
        completion([strongSelf.collections firstObject]);
        [self.tableView reloadData];
    }];
}

// Completion is called on main Queue
- (void)fetchCollectionsWithCompletion:(void(^)())success
{
    // Only fetch once every 30 seconds. This method is expensive and photo library can be noisy when syncing.
    if ([[NSDate date] timeIntervalSinceDate:self.lastFetch] < 30)
    {
        return;
    }
    
    NSMutableSet *newFetchResults = [[NSMutableSet alloc] init];
    PHAssetMediaType mediaType = self.mediaType;
    dispatch_async(self.serialFetchQueue, ^
    {
        // Fetch all albums
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                              subtype:PHAssetCollectionSubtypeAny
                                                                              options:nil];
        PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                             subtype:PHAssetCollectionSubtypeAny
                                                                             options:nil];
        [newFetchResults addObject:smartAlbums];
        [newFetchResults addObject:userAlbums];
        
        // Configure fetch options for media type and creation date
        PHFetchOptions *assetFetchOptions = [[PHFetchOptions alloc] init];
        assetFetchOptions.predicate = [NSPredicate predicateWithAssetMediaType:mediaType];
        assetFetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        
        // We're going to add appropriate collections and fetch requests to these arrays
        NSMutableArray *assetCollections = [[NSMutableArray alloc] init];
        NSMutableArray *assetCollectionsFetchResutls = [[NSMutableArray alloc] init];
        
        // Add collections and fetch requests to array if collection contains at least 1 asset of media type
        for (PHAssetCollection *collection in smartAlbums)
        {
            PHFetchResult *albumMediaTypeResults = [PHAsset fetchAssetsInAssetCollection:collection
                                                                                 options:assetFetchOptions];
            [newFetchResults addObject:albumMediaTypeResults];
            if (albumMediaTypeResults.count > 0)
            {
                // Make sure camera roll is the first collection that the user lands on
                if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary)
                {
                    [assetCollections insertObject:collection atIndex:0];
                    [assetCollectionsFetchResutls insertObject:albumMediaTypeResults atIndex:0];
                }
                else
                {
                    [assetCollections addObject:collection];
                    [assetCollectionsFetchResutls addObject:albumMediaTypeResults];
                }
            }
        }
        for (PHAssetCollection *collection in userAlbums)
        {
            PHFetchResult *albumMediaTypeResults = [PHAsset fetchAssetsInAssetCollection:collection
                                                                                 options:assetFetchOptions];
            [newFetchResults addObject:albumMediaTypeResults];
            if (albumMediaTypeResults.count > 0)
            {
                [assetCollections addObject:collection];
                [assetCollectionsFetchResutls addObject:albumMediaTypeResults];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^
        {
            self.lastFetch = [NSDate date];
            self.fetchResults = newFetchResults;
            self.collections = assetCollections;
            self.assetFetchResultForCollections = assetCollectionsFetchResutls;
            success();
        });
    });
}

#pragma mark - Private Methods

- (NSNumberFormatter *)createNumberFormatter
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    self.numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    self.numberFormatter.locale = [NSLocale currentLocale];
    self.numberFormatter.groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
    return formatter;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    return [[VCollectionListPresentationController alloc] initWithPresentedViewController:presented
                                                                 presentingViewController:source];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.animator.presenting = NO;
    return self.animator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.animator.presenting = YES;
    return self.animator;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
    if (CGRectContainsPoint(self.contentContainer.bounds, [touch locationInView:self.contentContainer]))
    {
        return NO;
    }
    return YES;
}

@end
