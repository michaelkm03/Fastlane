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
#import <MBProgressHUD/MBProgressHUD.h>
#import "VCompatibility.h"
#import "UIView+AutoLayout.h"
#import "NSIndexSet+Convenience.h"

// Image Resizing
#import "UIImage+Resize.h"

@import Photos;

@interface VAssetCollectionGridViewController () <UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver>

@property (nonatomic, assign) PHAssetMediaType mediaType;
@property (nonatomic, strong) PHCachingImageManager *imageManager;

@property (nonatomic, assign) CGRect previousPrefetchRect;

@property (nonatomic, strong) UIImage *selectedFullSizeImage;
@property (nonatomic, strong) NSURL *imageFileURL;
@property (nonatomic, strong) UIButton *alternateFolderButton;

@property (nonatomic, strong) PHFetchResult *assetsToDisplay;

@property (nonatomic, strong) VPermissionPhotoLibrary *libraryPermission;
@property (nonatomic, assign) BOOL needsFetch;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VAssetCollectionGridViewController

#pragma mark - Lifecycle Methods

+ (instancetype)assetGridViewControllerWithDependencyManager:(VDependencyManager *)dependencyManager
                                                   mediaType:(PHAssetMediaType)mediaType
{
    NSBundle *bundleForClass = [NSBundle bundleForClass:self];
    UIStoryboard *storyboardForClass = [UIStoryboard storyboardWithName:NSStringFromClass(self)
                                                                 bundle:bundleForClass];
    VAssetCollectionGridViewController *gridViewController = [storyboardForClass instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
    gridViewController.dependencyManager = dependencyManager;
    gridViewController.mediaType = mediaType;
    return gridViewController;
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.libraryPermission = [[VPermissionPhotoLibrary alloc] initWithDependencyManager:self.dependencyManager];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.libraryPermission permissionState] == VPermissionStateAuthorized)
    {
        [self prepareImageManagerAndRegisterAsObserver];
    }
    
    // NavigationItem titleView has a bug if you set a view with size zero
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    
    self.alternateFolderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.alternateFolderButton setTitle:@"asdf" forState:UIControlStateNormal];
    [self.alternateFolderButton setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.alternateFolderButton addTarget:self
                                   action:@selector(selectedFolderPicker:)
                         forControlEvents:UIControlEventTouchUpInside];
    self.alternateFolderButton.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:self.alternateFolderButton];
    
    UIImageView *dropdownImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gallery_dropdown_arrow"]];
    dropdownImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [dropdownImageView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [dropdownImageView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    [containerView addSubview:dropdownImageView];
    [containerView v_addPinToTopBottomToSubview:self.alternateFolderButton];
    [containerView v_addPinToTopBottomToSubview:dropdownImageView];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[alternateFolderButton][dropdownImageView]|"
                                                                          options:kNilOptions
                                                                          metrics:nil
                                                                            views:@{@"dropdownImageView":dropdownImageView,
                                                                                    @"alternateFolderButton":self.alternateFolderButton}]];
    
    self.navigationItem.titleView = containerView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    for (NSIndexPath *selectedIndexPaths in self.collectionView.indexPathsForSelectedItems)
    {
        [self.collectionView deselectItemAtIndexPath:selectedIndexPaths animated:NO];
    }
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
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", self.mediaType];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    self.assetsToDisplay = [PHAsset fetchAssetsInAssetCollection:collectionToDisplay
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
            numberOfItems = self.assetsToDisplay.count;
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
    PHAsset *assetAtIndexPath = [self assetForIndexPath:indexPath];
    [[PHImageManager defaultManager] requestImageForAsset:assetAtIndexPath
                                               targetSize:CGSizeMake(95, 95)
                                              contentMode:PHImageContentModeAspectFill
                                                  options:nil
                                            resultHandler:^(UIImage *result, NSDictionary *info)
     {
         VAssetCollectionViewCell *cellForResult = (VAssetCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
         cellForResult.imageView.image = result;
     }];
    
    return cell;
}

- (UICollectionViewCell *)allowAccessCellWithCollectionView:(UICollectionView *)collectionView
                                           forIndexPath:(NSIndexPath *)indexPath
{
    VLibraryAuthorizationCell *authorizationCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VLibraryAuthorizationCell suggestedReuseIdentifier]
                                                                                             forIndexPath:indexPath];
#warning Configure allow access text
    return authorizationCell;
}

- (UICollectionViewCell *)systemDeniedCellWithCollectionView:(UICollectionView *)collectionView
                                                forIndexPath:(NSIndexPath *)indexPath
{
    VLibraryAuthorizationCell *authorizationCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VLibraryAuthorizationCell suggestedReuseIdentifier]
                                                                                             forIndexPath:indexPath];
#warning Configure system denied text
    
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
            [self.libraryPermission requestPermissionInViewController:self
                                                withCompletionHandler:^(BOOL granted, VPermissionState state, NSError *error)
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
#warning Fix this
            return CGSizeMake(320.0, 320.0);
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
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // check if there are changes to the assets (insertions, deletions, updates)
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetsToDisplay];
        if (collectionChanges)
        {
            // get the new fetch result
            self.assetsToDisplay = [collectionChanges fetchResultAfterChanges];
            
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
                } completion:NULL];
            }
            
            [self resetCachedAssets];
        }
    });
}

#pragma mark - Private Methods

- (void)resetCachedAssets
{
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPrefetchRect = CGRectZero;
}

- (PHAsset *)assetForIndexPath:(NSIndexPath *)indexPath
{
    return [self.assetsToDisplay objectAtIndex:indexPath.row];
}

- (void)prepareImageManagerAndRegisterAsObserver
{
    self.imageManager = [[PHCachingImageManager alloc] init];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

@end
