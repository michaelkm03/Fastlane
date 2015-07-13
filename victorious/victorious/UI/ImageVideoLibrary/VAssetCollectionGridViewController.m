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
#warning Deal with new assets in our corrent asset collection
}

#pragma mark - Private Methods


- (PHAsset *)assetForIndexPath:(NSIndexPath *)indexPath
{
    return [self.assetsToDisplay objectAtIndex:indexPath.row];
}

- (void)prepareImageManagerAndRegisterAsObserver
{
    self.imageManager = [[PHCachingImageManager alloc] init];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

#warning Move this block to operations helper methods

//- (void)downloadAsset:(PHAsset *)asset
//{
//    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//    progressHud.mode = MBProgressHUDModeAnnularDeterminate;
//    progressHud.dimBackground = YES;
//    [progressHud show:YES];
//    
//    PHImageRequestOptions *fullSizeRequestOptions = [[PHImageRequestOptions alloc] init];
//    fullSizeRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
//    fullSizeRequestOptions.version = PHImageRequestOptionsVersionCurrent;
//    fullSizeRequestOptions.networkAccessAllowed = YES;
//    fullSizeRequestOptions.progressHandler = ^void(double progress, NSError *error, BOOL *stop, NSDictionary *info)
//    {
//        progressHud.progress = progress;
//    };
//    
//    __weak typeof(self) welf = self;
//    switch (asset.mediaType)
//    {
//        case PHAssetMediaTypeImage:
//        {
//            [[PHImageManager defaultManager] requestImageDataForAsset:asset
//                                                              options:fullSizeRequestOptions
//                                                        resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info)
//             {
//                 dispatch_async(dispatch_get_main_queue(), ^
//                                {
//                                    [welf callCompletionWithAsset:asset
//                                                        imageData:imageData
//                                                      orientation:orientation
//                                                             info:info];
//                                });
//             }];
//            break;
//        }
//        case PHAssetMediaTypeVideo:
//        {
//            [[PHImageManager defaultManager] requestExportSessionForVideo:asset
//                                                                  options:nil
//                                                             exportPreset:AVAssetExportPreset1280x720
//                                                            resultHandler:^(AVAssetExportSession *exportSession, NSDictionary *info)
//             {
//                 // Save video
//             }];
//            break;
//        }
//        default:
//        {
//            NSAssert(false, @"Unsopported photos media type.");
//            break;
//        }
//    }
//}

//- (void)callCompletionWithAsset:(PHAsset *)asset
//                      imageData:(NSData *)imageData
//                    orientation:(UIImageOrientation)orientation
//                           info:(NSDictionary *)info
//{
//    __weak typeof(self) welf = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
//    {
//        UIImage *imageFromData = [UIImage imageWithData:imageData];
//        UIImage *imageWithProperOrientation = [[UIImage imageWithCGImage:imageFromData.CGImage scale:1.0f orientation:orientation] fixOrientation];
//        NSURL *urlForAsset = [welf temporaryURLForAsset:asset];
//        [welf saveImage:imageWithProperOrientation
//                  toURL:urlForAsset];
//        dispatch_async(dispatch_get_main_queue(), ^
//        {
//            MBProgressHUD *hudForView = [MBProgressHUD HUDForView:self.navigationController.view];
//            [hudForView hide:YES];
//            
//            __strong typeof (welf) strongSelf = welf;
//            strongSelf.selectedFullSizeImage = imageWithProperOrientation;
//            strongSelf.imageFileURL = urlForAsset;
//
//            if (strongSelf.handler != nil)
//            {
//                strongSelf.handler(strongSelf.selectedFullSizeImage, strongSelf.imageFileURL);
//            }
//        });
//    });
//}

//- (void)saveImage:(UIImage *)image
//            toURL:(NSURL *)fileURL
//{
//    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
//    NSError *error = nil;
//    [imageData writeToURL:fileURL options:NSDataWritingAtomic error:&error];
//}

//- (NSURL *)temporaryURLForAsset:(PHAsset *)asset
//{
//    NSURL *baseURL = [self cacheDirectoryURL];
//    
//    NSUUID *uuid = [NSUUID UUID];
//    
//    return [baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", uuid.UUIDString]];
//}
//
//- (NSURL *)cacheDirectoryURL
//{
//    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
//}

@end
