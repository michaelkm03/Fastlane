//
//  VEStreamCellFactory.m
//  victorious
//
//  Created by Michael Sena on 4/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEStreamCellFactory.h"

// Models
#import "VSequence+Fetcher.h"

// Cells
#import "VEStreamCollectionViewCell.h"

@interface VEStreamCellFactory ()

@property (nonatomic, readonly) VDependencyManager *dependencyManager;

@end

@implementation VEStreamCellFactory

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[VEStreamCollectionViewCell nibForCell]
     forCellWithReuseIdentifier:[VEStreamCollectionViewCell suggestedReuseIdentifier]];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                       cellForStreamItem:(VStreamItem *)streamItem
                             atIndexPath:(NSIndexPath *)indexPath
{
    NSAssert( [streamItem isKindOfClass:[VSequence class]], @"This factory can only handle VSequence objects" );
    
    VSequence *sequence = (VSequence *)streamItem;
    
    VEStreamCollectionViewCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VEStreamCollectionViewCell suggestedReuseIdentifier]
                                                                                               forIndexPath:indexPath];
    
    
    return collectionViewCell;
}

- (CGFloat)minimumLineSpacing
{
    return 32.0f;
}

- (CGSize)sizeWithCollectionViewBounds:(CGRect)bounds ofCellForStreamItem:(VStreamItem *)streamItem
{
    return CGSizeMake(CGRectGetWidth(bounds), CGRectGetWidth(bounds));
}

- (UIEdgeInsets)sectionInsets
{
    return UIEdgeInsetsZero;
}

@end
