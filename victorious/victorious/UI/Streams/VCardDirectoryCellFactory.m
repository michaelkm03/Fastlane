//
//  VCardDirectoryCellFactory.m
//  victorious
//
//  Created by Sharif Ahmed on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCardDirectoryCellFactory.h"
#import "VDependencyManager.h"
#import "VDirectoryItemCell.h"

@interface VCardDirectoryCellFactory ()

@property (nonatomic, strong) UICollectionViewLayout *collectionViewLayout;

@end
/*
@implementation VCardDirectoryCellFactory

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (UICollectionViewLayout *)collectionViewLayout
{
    if ( _collectionViewLayout != nil )
    {
        return _collectionViewLayout;
    }
    
    _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    return _collectionViewLayout;
}

- (CGSize)desiredSizeForCollectionViewBounds:(CGRect)bounds andStreamItem:(VStreamItem *)streamItem
{
    return [VDirectoryGroupCell desiredSizeWithCollectionViewBounds:bounds];
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[VDirectoryGroupCell nibForCell] forCellWithReuseIdentifier:[VDirectoryGroupCell suggestedReuseIdentifier]];
}

- (NSObject <VDirectoryCellFactory> *)cellFactoryForStreamOfStreams:(VStream *)streamOfStreams
{
    return [[VShowcaseCellFactory alloc] initWithDependencyManager:self.dependencyManager];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForIndexPath:(NSIndexPath *)indexPath withStreamItem:(VStreamItem *)streamItem
{
    NSString *identifier = [VDirectoryGroupCell suggestedReuseIdentifier];
    VDirectoryGroupCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.stream = (VStream *)streamItem;
    cell.dependencyManager = self.dependencyManager;
    return cell;
}

- (CGFloat)minimumInterItemSpacing
{
    return 0.0f;
}

- (CGFloat)minimumLineSpacing
{
    return 1.0f;
}

- (UIEdgeInsets)sectionEdgeInsets
{
    return UIEdgeInsetsMake(kStreamDirectoryGroupCellInset, 0.0f, kDirectoryInset, 0.0f);
}

@end
*/