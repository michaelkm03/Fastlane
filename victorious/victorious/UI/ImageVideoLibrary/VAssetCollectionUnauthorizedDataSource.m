//
//  VAssetCollectionUnauthorizedDataSource.m
//  victorious
//
//  Created by Michael Sena on 7/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAssetCollectionUnauthorizedDataSource.h"

#import "VDependencyManager.h"

// Views
#import "VLibraryAuthorizationCell.h"

// Permissions
#import "VPermissionPhotoLibrary.h"

static NSString * const kAccessUndeterminedPromptKey = @"accessUndeterminedPrompt";
static NSString * const kAccessUndeterminedCalltoActionKey = @"accessUndeterminedCallToAction";
static NSString * const kAccessDeniedPromptKey = @"accessDeniedPrompt";
static NSString * const kNotAuthorizedTextColorKey = @"notAuthorizedTextColor";
static NSString * const kNotAuthorizedPromptFont = @"notAuthorizedPromptFont";
static NSString * const kNotAuthorizedCallToActionFont = @"notAuthorizedCallToActionFont";

@interface VAssetCollectionUnauthorizedDataSource ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VPermissionPhotoLibrary *libraryPermission;

@end

@implementation VAssetCollectionUnauthorizedDataSource

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
        _libraryPermission = [[VPermissionPhotoLibrary alloc] initWithDependencyManager:dependencyManager];
    }
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VLibraryAuthorizationCell *authorizationCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VLibraryAuthorizationCell suggestedReuseIdentifier]
                                                                                             forIndexPath:indexPath];
    BOOL isAllowAccess = [self.libraryPermission permissionState] == VPermissionStateUnknown;
    authorizationCell.promptText = [self.dependencyManager stringForKey:isAllowAccess ? kAccessUndeterminedPromptKey : kAccessDeniedPromptKey];
    authorizationCell.promptFont = [self.dependencyManager fontForKey:kNotAuthorizedPromptFont];
    authorizationCell.promptColor = [self.dependencyManager colorForKey:kNotAuthorizedTextColorKey];
    authorizationCell.callToActionText = [self.dependencyManager stringForKey:isAllowAccess ? kAccessUndeterminedCalltoActionKey : nil];
    authorizationCell.callToActionFont = [self.dependencyManager fontForKey:kNotAuthorizedCallToActionFont];
    authorizationCell.callToActionColor = [self.dependencyManager colorForKey:kNotAuthorizedTextColorKey];
    authorizationCell.accessibilityIdentifier = VAutomationIdentifierGrantLibraryAccess;
    return authorizationCell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewFlowLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat insetSize = CGRectGetWidth(collectionView.bounds) - collectionViewLayout.sectionInset.left - collectionViewLayout.sectionInset.right;
    return CGSizeMake(insetSize, insetSize);
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
                 }
                 [self.delegate unauthorizedDataSource:self authorizationChangedTo:granted];

             }];
            break;
            break;
        }
        case VPermissionStateAuthorized:
        case VPermissionStateSystemDenied:
        case VPermissionStateUnsupported:
            // Nothing to do here
            break;
    }
}

@end
