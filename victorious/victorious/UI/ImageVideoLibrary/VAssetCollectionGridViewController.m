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
#import "VAssetCollectionGridDataSource.h"
#import "VAssetCollectionUnauthorizedDataSource.h"
#import "UIView+AutoLayout.h"

// Image Resizing
#import "UIImage+Resize.h"

#import <MBProgressHUD/MBProgressHUD.h>
@import Photos;

NSString * const VAssetCollectionGridViewControllerMediaType = @"assetGridViewControllerMediaType";

@interface VAssetCollectionGridViewController () <VAssetCollectionUnauthorizedDataSourceDelegate, VAssetCollectionGridDataSourceDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) VPermissionPhotoLibrary *libraryPermission;
@property (nonatomic, strong) VAssetCollectionGridDataSource *assetDataSource;
@property (nonatomic, strong) VAssetCollectionUnauthorizedDataSource *unauthorizedDataSource;
@property (nonatomic, assign) PHAssetMediaType mediaType;

@property (nonatomic, strong) UIButton *alternateFolderButton;
@property (nonatomic, strong) UIImageView *dropdownImageView;

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

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
    gridViewController.libraryPermission = [[VPermissionPhotoLibrary alloc] initWithDependencyManager:dependencyManager];
    return gridViewController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    switch ([self.libraryPermission permissionState])
    {
        case VPermissionStatePromptDenied:
        case VPermissionStateUnknown:
        case VPermissionStateSystemDenied:
        case VPermissionUnsupported:
            self.unauthorizedDataSource = [[VAssetCollectionUnauthorizedDataSource alloc] initWithDependencyManager:self.dependencyManager];
            self.unauthorizedDataSource.delegate = self;
            [self setCollectionViewDataSourceTo:self.unauthorizedDataSource];
            break;
        case VPermissionStateAuthorized:
            [self.activityIndicator startAnimating];
            [self setupAssetDataSource];
            [self setCollectionViewDataSourceTo:self.assetDataSource];
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

    if (_collectionToDisplay == nil)
    {
        return;
    }
    
    [self.activityIndicator stopAnimating];
    [self.alternateFolderButton setTitle:collectionToDisplay.localizedTitle
                                forState:UIControlStateNormal];
    self.dropdownImageView.hidden = NO;
    
    self.assetDataSource.assetCollection = collectionToDisplay;
}

- (void)setDelegate:(id<VAssetCollectionGridViewControllerDelegate>)delegate
{
    _delegate = delegate;
    
    switch ([self.libraryPermission permissionState])
    {
        case VPermissionStatePromptDenied:
        case VPermissionStateUnknown:
            break;
        case VPermissionStateSystemDenied:
            [self.delegate gridViewController:self
                          authorizationStatus:NO];
            break;
        case VPermissionStateAuthorized:
            [self.delegate gridViewController:self
                          authorizationStatus:NO];
            break;
        case VPermissionUnsupported:
            // We should never get here
            break;
    }
}

#pragma mark - Target / Action

- (void)selectedFolderPicker:(UIButton *)button
{
    [self.delegate gridViewControllerWantsToViewAlternateCollections:self];
}

#pragma mark - VAssetCollectionUnauthorizedDataSourceDelegate

- (void)unauthorizedDataSource:(VAssetCollectionUnauthorizedDataSource *)dataSource
        authorizationChangedTo:(BOOL)authorizationStatus
{
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

@end
