//
//  VAssetCollectionUnauthorizedDataSource.m
//  victorious
//
//  Created by Michael Sena on 7/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAssetCollectionUnauthorizedDataSource.h"

#import "VDependencyManager.h"

// Permissions
#import "VPermissionPhotoLibrary.h"

@interface VAssetCollectionUnauthorizedDataSource ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VAssetCollectionUnauthorizedDataSource

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}


@end
