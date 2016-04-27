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
#import "VAssetCollectionListViewController.h"
#import "VAssetCollectionGridDataSource.h"
#import "VNoAssetsDataSource.h"
#import "VAssetCollectionUnauthorizedDataSource.h"
#import "UIView+AutoLayout.h"
#import "VLibraryFolderControl.h"

// Image Resizing
#import "UIImage+Resize.h"

#import <MBProgressHUD/MBProgressHUD.h>
@import Photos;

NSString * const VAssetCollectionGridViewControllerMediaType = @"assetGridViewControllerMediaType";

static NSString * const kImageTitleKey = @"imageTitle";
static NSString * const kVideoTitleKey = @"videoTitle";
static NSString * const kMixedMediaTitleKey = @"mixedMediaTitle";

@interface VAssetCollectionGridViewController () <VAssetCollectionUnauthorizedDataSourceDelegate, VAssetCollectionGridDataSourceDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) VAssetCollectionListViewController *listViewController;

@property (nonatomic, strong) VPermissionPhotoLibrary *libraryPermission;
@property (nonatomic, strong) VAssetCollectionGridDataSource *assetDataSource;
@property (nonatomic, strong) VAssetCollectionUnauthorizedDataSource *unauthorizedDataSource;
@property (nonatomic, strong) VNoAssetsDataSource *noAssetsDataSource;
@property (nonatomic, assign) PHAssetMediaType mediaType;

@property (nonatomic, strong) VLibraryFolderControl *folderButton;

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

// MARK: - Private dependency manager value accessors

@interface VDependencyManager (localProperties)

- (NSString *)titleTextForMediaType:(PHAssetMediaType)mediaType;

@end

@implementation VDependencyManager (localProperties)

- (NSString *)titleTextForMediaType:(PHAssetMediaType)mediaType
{
    switch (mediaType)
    {
        case PHAssetMediaTypeImage:
            return [self stringForKey:kImageTitleKey];
        case PHAssetMediaTypeVideo:
            return [self stringForKey:kVideoTitleKey];
        case PHAssetMediaTypeUnknown:
            return [self stringForKey:kMixedMediaTitleKey];
        default:
            return nil;
    }
}

@end

// MARK: - Class implementation

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
    gridViewController.libraryPermission = [[VPermissionPhotoLibrary alloc] initWithDependencyManager:dependencyManager];
    gridViewController.listViewController = [VAssetCollectionListViewController assetCollectionListViewControllerWithMediaType:gridViewController.mediaType];
    gridViewController.noAssetsDataSource = [[VNoAssetsDataSource alloc] initWithMediaType:gridViewController.mediaType];
    return gridViewController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.accessibilityIdentifier = VAutomationIdentifierMediaGalleryCollection;
    self.definesPresentationContext = YES;
    switch ([self.libraryPermission permissionState])
    {
        case VPermissionStatePromptDenied:
        case VPermissionStateUnknown:
        case VPermissionStateSystemDenied:
        case VPermissionStateUnsupported:
            self.unauthorizedDataSource = [[VAssetCollectionUnauthorizedDataSource alloc] initWithDependencyManager:self.dependencyManager];
            self.unauthorizedDataSource.delegate = self;
            [self setCollectionViewDataSourceTo:self.unauthorizedDataSource];
            self.collectionView.alpha = 1.0f;
            break;
        case VPermissionStateAuthorized:
            [self.activityIndicator startAnimating];
            [self setupAssetDataSource];
            [self setCollectionViewDataSourceTo:self.assetDataSource];
            [self fetchDefaultCollection];
            break;
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
    
    [self.assetDataSource updateCachedAssets];
}

#pragma mark - Property Accessors

- (void)setCollectionToDisplay:(PHAssetCollection *)collectionToDisplay
{
    _collectionToDisplay = collectionToDisplay;

    [self.activityIndicator stopAnimating];
    
    if (_collectionToDisplay == nil)
    {
        [self.activityIndicator stopAnimating];
        self.collectionView.alpha = 1.0f;
        [self setCollectionViewDataSourceTo:self.noAssetsDataSource];
        return;
    }
    
    self.folderButton.attributedSubtitle = [[NSAttributedString alloc] initWithString:collectionToDisplay.localizedTitle attributes:nil];
    
    self.assetDataSource.assetCollection = collectionToDisplay;
    [UIView animateWithDuration:0.35f
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.collectionView.alpha = 1.0f;
     }
                     completion:nil];
}

#pragma mark - Target / Action

- (void)selectedFolderPicker:(VLibraryFolderControl *)folderControl
{
    [self presentAssetFoldersList];
}

#pragma mark - VAssetCollectionUnauthorizedDataSourceDelegate

- (void)unauthorizedDataSource:(VAssetCollectionUnauthorizedDataSource *)dataSource
        authorizationChangedTo:(BOOL)authorizationStatus
{
    __weak typeof(self) welf = self;
    [self.listViewController fetchDefaultCollectionWithCompletion:^(PHAssetCollection *collection)
     {
         __strong typeof(welf) strongSelf = welf;
         strongSelf.collectionToDisplay = collection;
     }];
    if (authorizationStatus)
    {
        [self setupAssetDataSource];
        [self setCollectionViewDataSourceTo:self.assetDataSource];
        [self.activityIndicator startAnimating];
    }
}

#pragma mark - VAssetCollectionGridDataSourceDelegate

- (void)assetCollectionDataSource:(VAssetCollectionGridDataSource *)dataSource
                    selectedAsset:(PHAsset *)asset
{
    [self.delegate gridViewController:self selectedAsset:asset];
}

#pragma mark - Private Methods

- (void)fetchDefaultCollection
{
    // Bail early if we already have a collection
    if (self.collectionToDisplay != nil)
    {
        return;
    }
    
    __weak typeof(self) welf = self;
    [self.listViewController fetchDefaultCollectionWithCompletion:^(PHAssetCollection *collection)
     {
         __strong typeof(welf) strongSelf = welf;
         strongSelf.collectionToDisplay = collection;
     }];
}

- (void)presentAssetFoldersList
{
    // Present alternate folder
    __weak typeof(self) welf = self;
    self.listViewController.collectionSelectionHandler = ^void(PHAssetCollection *assetCollection)
    {
        __strong typeof(welf) strongSelf = welf;
        strongSelf.collectionToDisplay = assetCollection;
    };
    [self presentViewController:self.listViewController animated:YES completion:nil];
}

- (void)setCollectionViewDataSourceTo:(id <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>)dataSource
{
    self.collectionView.dataSource = dataSource;
    self.collectionView.delegate = dataSource;
    [self.collectionView reloadData];
}

- (void)setupAssetDataSource
{
    self.assetDataSource = [[VAssetCollectionGridDataSource alloc] initWithMediaType:self.mediaType];
    self.assetDataSource.collectionView = self.collectionView;
    self.assetDataSource.delegate = self;
}

- (UIView *)createContainerViewForAlternateCollectionSelection
{   
    self.folderButton = [VLibraryFolderControl newFolderControl];
    NSString *titleText = [self.dependencyManager titleTextForMediaType:self.mediaType];
    self.folderButton.attributedTitle = [[NSAttributedString alloc] initWithString:titleText attributes:nil];
    self.folderButton.attributedSubtitle = nil;
    [self.folderButton addTarget:self action:@selector(selectedFolderPicker:) forControlEvents:UIControlEventTouchUpInside];
    return self.folderButton;
}

@end
