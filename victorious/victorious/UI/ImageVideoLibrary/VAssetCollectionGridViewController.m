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

#warning Remove these?
#import "VAssetCollectionViewCell.h"
#import "VLibraryAuthorizationCell.h"
#import "UIView+AutoLayout.h"

// Image Resizing
#import "UIImage+Resize.h"

#import <MBProgressHUD/MBProgressHUD.h>
@import Photos;

NSString * const VAssetCollectionGridViewControllerMediaType = @"assetGridViewControllerMediaType";
static NSString * const kAccessUndeterminedPromptKey = @"accessUndeterminedPrompt";
static NSString * const kAccessUndeterminedCalltoActionKey = @"accessUndeterminedCalltoAction";
static NSString * const kAccessDeniedPromptKey = @"accessDeniedPrompt";
static NSString * const kNotAuthorizedTextColorKey = @"notAuthorizedTextColor";
static NSString * const kNotAuthorizedPromptFont = @"notAuthorizedPromptFont";
static NSString * const kNotAuthorizedCallToActionFont = @"notAuthorizedCallToActionFont";

@interface VAssetCollectionGridViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) VPermissionPhotoLibrary *libraryPermission;
@property (nonatomic, strong) VAssetCollectionGridDataSource *assetDataSource;
@property (nonatomic, assign) PHAssetMediaType mediaType;

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
    gridViewController.assetDataSource = [[VAssetCollectionGridDataSource alloc] initWithMediaType:gridViewController.mediaType];
    gridViewController.libraryPermission = [[VPermissionPhotoLibrary alloc] initWithDependencyManager:dependencyManager];
    return gridViewController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.assetDataSource.collectionView = self.collectionView;

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
#warning Remove me
            numberOfItems = -1;
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
#warning CREATE UNAUTHORIZED DATA SOURCE
            break;
        case VPermissionStateAuthorized:
        case VPermissionUnsupported:
            // We should never get here
            break;
    }
    
    return cell;
}

#pragma mark Helpers

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
#warning Should setup data source here?
//                    [self prepareImageManagerAndRegisterAsObserver];
                }
                [self.delegate gridViewController:self
                              authorizationStatus:granted];
                [self.collectionView reloadData];
            }];
            break;
            break;
        }
        case VPermissionStateAuthorized:
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
        case VPermissionUnsupported:
            return CGSizeZero;
            break;
    }
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

@end
