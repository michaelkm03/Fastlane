//
//  VAssetGridViewController.m
//  victorious
//
//  Created by Michael Sena on 6/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAssetCollectionGridViewController.h"

// Permissions
#import "VPermissionPhotoLibrary.h"

// Views + Helpers
#import "VAssetCollectionViewCell.h"
#import "VLibraryAuthorizationCell.h"
#import "UIView+AutoLayout.h"
#import "NSIndexSet+Convenience.h"
#import "UICollectionView+Convenience.h"

// Image Resizing
#import "UIImage+Resize.h"

#import <MBProgressHUD/MBProgressHUD.h>
@import Photos;

static NSInteger const kScreenSizeCacheTrigger = 3.0f;

NSString * const VAssetCollectionGridViewControllerMediaType = @"assetGridViewControllerMediaType";
static NSString * const kAccessUndeterminedPromptKey = @"accessUndeterminedPrompt";
static NSString * const kAccessUndeterminedCalltoActionKey = @"accessUndeterminedCalltoAction";
static NSString * const kAccessDeniedPromptKey = @"accessDeniedPrompt";
static NSString * const kNotAuthorizedTextColorKey = @"notAuthorizedTextColor";
static NSString * const kNotAuthorizedPromptFont = @"notAuthorizedPromptFont";
static NSString * const kNotAuthorizedCallToActionFont = @"notAuthorizedCallToActionFont";

@interface VAssetCollectionGridViewController () <UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) VPermissionPhotoLibrary *libraryPermission;
@property (nonatomic, assign) PHAssetMediaType mediaType;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) PHFetchResult *fetchResultForAssetsToDisplay;

@property (nonatomic, assign) CGRect previousPrefetchRect;

@property (nonatomic, strong) UIImage *selectedFullSizeImage;
@property (nonatomic, strong) NSURL *imageFileURL;
@property (nonatomic, strong) UIButton *alternateFolderButton;
@property (nonatomic, strong) UIImageView *dropdownImageView;

@end

@implementation VAssetCollectionGridViewController

#pragma mark - Lifecycle Methods

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSBundle *bundleForClass = [NSBundle bundleForClass:self];
    UIStoryboard *storyboardForClass = [UIStoryboard storyboardWithName:NSStringFromClass(self)
                                                                 bundle:bundleForClass];
    VAssetCollectionGridViewController *gridViewController = [storyboardForClass instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
    gridViewController.dependencyManager = dependencyManager;
    gridViewController.mediaType = [[dependencyManager numberForKey:VAssetCollectionGridViewControllerMediaType] integerValue];
    return gridViewController;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        _libraryPermission = [[VPermissionPhotoLibrary alloc] initWithDependencyManager:self.dependencyManager];
    }
    return self;
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.libraryPermission permissionState] == VPermissionStateAuthorized)
    {
        [self prepareImageManagerAndRegisterAsObserver];
    }

    self.navigationItem.titleView = [self createContainerViewForAlternateCollectionSelection];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    for (NSIndexPath *selectedIndexPaths in self.collectionView.indexPathsForSelectedItems)
    {
        [self.collectionView deselectItemAtIndexPath:selectedIndexPaths animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateCachedAssets];
}

#pragma mark - Property Accessors

- (void)setCollectionToDisplay:(PHAssetCollection *)collectionToDisplay
{
    _collectionToDisplay = collectionToDisplay;

    if (_collectionToDisplay == nil)
    {
        return;
    }
    
    [self.alternateFolderButton setTitle:collectionToDisplay.localizedTitle
                                forState:UIControlStateNormal];
    self.dropdownImageView.hidden = NO;
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", self.mediaType];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    self.fetchResultForAssetsToDisplay = [PHAsset fetchAssetsInAssetCollection:collectionToDisplay
                                                         options:fetchOptions];

    // Reload and scroll to top
    [self.collectionView reloadData];
    if ([self.collectionView numberOfItemsInSection:0] > 0)
    {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionTop
                                            animated:NO];
    }
}

- (void)setOnAuthorizationHandler:(void (^)(BOOL))onAuthorizationHandler
{
    _onAuthorizationHandler = onAuthorizationHandler;
    
    // If authorization handler is being cleared bail
    if (_onAuthorizationHandler == nil)
    {
        return;
    }
    
    switch ([self.libraryPermission permissionState])
    {
        case VPermissionStatePromptDenied:
        case VPermissionStateUnknown:
            break;
        case VPermissionStateSystemDenied:
            onAuthorizationHandler(NO);
            break;
        case VPermissionStateAuthorized:
            onAuthorizationHandler(YES);
            break;
        case VPermissionUnsupported:
            // We should never get here
            break;
    }
}

#pragma mark - Target / Action

- (void)selectedFolderPicker:(UIButton *)button
{
    if (self.alternateFolderSelectionHandler != nil)
    {
        self.alternateFolderSelectionHandler();
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numberOfItems;
    switch ([self.libraryPermission permissionState])
    {
        case VPermissionStatePromptDenied:
        case VPermissionStateUnknown:
        case VPermissionStateSystemDenied:
            // We treat all of these the same as 1 since we show our authorization cell.
            numberOfItems = 1;
            break;
        case VPermissionStateAuthorized:
            numberOfItems = self.fetchResultForAssetsToDisplay.count;
            break;
        case VPermissionUnsupported:
            // We should never get here
            numberOfItems = 0;
            break;
    }
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;
    
    switch ([self.libraryPermission permissionState])
    {
        case VPermissionStatePromptDenied:
        case VPermissionStateUnknown:
            // Show the allow access cell
            cell = [self allowAccessCellWithCollectionView:collectionView
                                              forIndexPath:indexPath];
            break;
        case VPermissionStateSystemDenied:
            // Show the fix in settings
            cell = [self assetCellWithCollectionView:collectionView
                                        andIndexPath:indexPath];
            break;
        case VPermissionStateAuthorized:
            // We're all good show the asset cell
            cell = [self assetCellWithCollectionView:collectionView andIndexPath:indexPath];
            break;
        case VPermissionUnsupported:
            // We should never get here
            break;
    }
    
    return cell;
}

#pragma mark Helpers

- (UICollectionViewCell *)assetCellWithCollectionView:(UICollectionView *)collectionView
                                         andIndexPath:(NSIndexPath *)indexPath
{
    VAssetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VAssetCollectionViewCell suggestedReuseIdentifier]
                                                                               forIndexPath:indexPath];
    
    // Configure cell for asset
    cell.imageManager = self.imageManager;
    PHAsset *assetAtIndexPath = [self assetForIndexPath:indexPath];
    cell.asset = assetAtIndexPath;
    
    return cell;
}

- (UICollectionViewCell *)allowAccessCellWithCollectionView:(UICollectionView *)collectionView
                                           forIndexPath:(NSIndexPath *)indexPath
{
    VLibraryAuthorizationCell *authorizationCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VLibraryAuthorizationCell suggestedReuseIdentifier]
                                                                                             forIndexPath:indexPath];
    authorizationCell.promptText = [self.dependencyManager stringForKey:kAccessUndeterminedPromptKey];
    authorizationCell.promptFont = [self.dependencyManager fontForKey:kNotAuthorizedPromptFont];
    authorizationCell.promptColor = [self.dependencyManager colorForKey:kNotAuthorizedTextColorKey];
    authorizationCell.callToActionText = [self.dependencyManager stringForKey:kAccessUndeterminedCalltoActionKey];
    authorizationCell.callToActionFont = [self.dependencyManager fontForKey:kNotAuthorizedCallToActionFont];
    authorizationCell.callToActionColor = [self.dependencyManager colorForKey:kNotAuthorizedTextColorKey];
    
    return authorizationCell;
}

- (UICollectionViewCell *)systemDeniedCellWithCollectionView:(UICollectionView *)collectionView
                                                forIndexPath:(NSIndexPath *)indexPath
{
    VLibraryAuthorizationCell *authorizationCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VLibraryAuthorizationCell suggestedReuseIdentifier]
                                                                                             forIndexPath:indexPath];
    authorizationCell.promptText = [self.dependencyManager stringForKey:kAccessDeniedPromptKey];
    authorizationCell.promptFont = [self.dependencyManager fontForKey:kNotAuthorizedPromptFont];
    authorizationCell.promptColor = [self.dependencyManager colorForKey:kNotAuthorizedTextColorKey];
    authorizationCell.callToActionText = nil;
    
    return authorizationCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([self.libraryPermission permissionState])
    {
        case VPermissionStatePromptDenied:
        case VPermissionStateUnknown:
        {
            // Show the permission request
            [self.libraryPermission requestSystemPermissionWithCompletion:^(BOOL granted, VPermissionState state, NSError *error)
            {
                if (state == VPermissionStateAuthorized)
                {
                    [self prepareImageManagerAndRegisterAsObserver];
                }
                if (self.onAuthorizationHandler != nil)
                {
                    self.onAuthorizationHandler(granted);
                }
                [self.collectionView reloadData];
            }];
            break;
            break;
        }
        case VPermissionStateAuthorized:
        {
            // We're all good call the asset selection handler
            if (self.assetSelectionHandler)
            {
                self.assetSelectionHandler([self assetForIndexPath:indexPath]);
            }
            break;
        }
        case VPermissionStateSystemDenied:
        case VPermissionUnsupported:
            // Nothing to do here
            break;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewFlowLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([self.libraryPermission permissionState])
    {
        case VPermissionStatePromptDenied:
        case VPermissionStateSystemDenied:
        case VPermissionStateUnknown:
        {
            CGFloat insetSize = CGRectGetWidth(collectionView.bounds) - collectionViewLayout.sectionInset.left - collectionViewLayout.sectionInset.right;
            return CGSizeMake(insetSize, insetSize);
        }
            break;
        case VPermissionStateAuthorized:
        {
            CGFloat fullWidth = CGRectGetWidth(collectionView.bounds);
            CGFloat widthWithoutInsetAndPadding = fullWidth - collectionViewLayout.sectionInset.left - collectionViewLayout.sectionInset.right - (2 * collectionViewLayout.minimumInteritemSpacing);
            CGFloat itemWidth = widthWithoutInsetAndPadding / 3;
            return CGSizeMake(VFLOOR(itemWidth), VFLOOR(itemWidth));
        }
        case VPermissionUnsupported:
            return CGSizeZero;
            break;
    }
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^
    {
        // check if there are changes to the assets (insertions, deletions, updates)
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.fetchResultForAssetsToDisplay];
        if (collectionChanges)
        {
            // get the new fetch result
            self.fetchResultForAssetsToDisplay = [collectionChanges fetchResultAfterChanges];
            
            UICollectionView *collectionView = self.collectionView;
            
            if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves])
            {
                // we need to reload all if the incremental diffs are not available
                [collectionView reloadData];
            }
            else
            {
                // if we have incremental diffs, tell the collection view to animate insertions and deletions
                [collectionView performBatchUpdates:^
                {
                    NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                    if ([removedIndexes count])
                    {
                        [collectionView deleteItemsAtIndexPaths:[removedIndexes indexPathsFromIndexesWithSecion:0]];
                    }
                    NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                    if ([insertedIndexes count])
                    {
                        [collectionView insertItemsAtIndexPaths:[insertedIndexes indexPathsFromIndexesWithSecion:0]];
                    }
                    NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                    if ([changedIndexes count])
                    {
                        [collectionView reloadItemsAtIndexPaths:[changedIndexes indexPathsFromIndexesWithSecion:0]];
                    }
                    [collectionChanges enumerateMovesWithBlock:^(NSUInteger fromIndex, NSUInteger toIndex)
                    {
                        [collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:toIndex inSection:0]]];
                    }];
                } completion:NULL];
            }
            
            [self resetCachedAssets];
        }
    });
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssets];
}

#pragma mark - Private Methods

- (UIView *)createContainerViewForAlternateCollectionSelection
{
    // NavigationItem titleView doesn't resize properly. Give it a "big enough" starting size
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    
    self.alternateFolderButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.alternateFolderButton setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.alternateFolderButton addTarget:self
                                   action:@selector(selectedFolderPicker:)
                         forControlEvents:UIControlEventTouchUpInside];
    self.alternateFolderButton.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:self.alternateFolderButton];
    
    self.dropdownImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gallery_dropdown_arrow"]];
    self.dropdownImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.dropdownImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.dropdownImageView.hidden = YES;
    [containerView addSubview:self.dropdownImageView];
    [containerView v_addPinToTopBottomToSubview:self.alternateFolderButton];
    [containerView v_addPinToTopBottomToSubview:self.dropdownImageView];
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.alternateFolderButton
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:containerView
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0f
                                                               constant:0.0f]];
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.dropdownImageView
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.alternateFolderButton
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1.0f
                                                               constant:0.0f]];
    return containerView;
}

- (void)resetCachedAssets
{
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPrefetchRect = CGRectZero;
}

- (void)updateCachedAssets
{
    BOOL isAuthorized = [self.libraryPermission permissionState] == VPermissionStateAuthorized;
    if (![self isViewLoaded] || !isAuthorized)
    {
        return;
    }
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPrefetchRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) / kScreenSizeCacheTrigger)
    {
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPrefetchRect
                                   andRect:preheatRect
                            removedHandler:^(CGRect removedRect)
        {
            NSArray *indexPaths = [self.collectionView indexPathsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        }
                              addedHandler:^(CGRect addedRect)
        {
            NSArray *indexPaths = [self.collectionView indexPathsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:[self desiredImageSize]
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:[self desiredImageSize]
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        self.previousPrefetchRect = preheatRect;
    }
}

- (CGSize)desiredImageSize
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = [self collectionView:self.collectionView
                                    layout:self.collectionViewLayout
                    sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    return CGSizeMake(cellSize.width * scale, cellSize.height * scale);
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect))
    {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        if (newMaxY > oldMaxY)
        {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY)
        {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY)
        {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY)
        {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    }
    else
    {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (PHAsset *)assetForIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchResultForAssetsToDisplay objectAtIndex:indexPath.row];
}

- (void)prepareImageManagerAndRegisterAsObserver
{
    self.imageManager = [[PHCachingImageManager alloc] init];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count == 0)
    {
        return nil;
    }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths)
    {
        PHAsset *asset = self.fetchResultForAssetsToDisplay[indexPath.item];
        [assets addObject:asset];
    }
    return assets;
}

@end
