//
//  VShowcaseCellFactory.m
//  victorious
//
//  Created by Sharif Ahmed on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VShowcaseCellFactory.h"
#import "VDependencyManager.h"
#import "VDirectoryGroupCell.h"
#import "VStreamItem+Fetcher.h"
#import "VStream.h"

static CGFloat const kDirectoryInset = 5.0f;
static NSString * const kGroupedDirectoryCellFactoryKey = @"groupedCell";

@interface VShowcaseCellFactory ()

@property (nonatomic, strong) UICollectionViewLayout *collectionViewLayout;
@property (nonatomic, strong) NSObject <VNestedDirectoryCellFactory> *groupedDirectoryCellFactory;

@end

@implementation VShowcaseCellFactory

@synthesize dependencyManager;

- (instancetype)initWithDependencyManager:(VDependencyManager *)localDependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        dependencyManager = localDependencyManager;
        _groupedDirectoryCellFactory = [dependencyManager templateValueConformingToProtocol:@protocol(VNestedDirectoryCellFactory) forKey:kGroupedDirectoryCellFactoryKey];
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
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat cellHeight = [self.groupedDirectoryCellFactory desiredSizeForCollectionViewBounds:bounds andStreamItem:streamItem].height;
    CGFloat height = [VDirectoryGroupCell desiredContentHeightForWidth:width cellHeight:cellHeight andInsets:self.groupedDirectoryCellFactory.sectionEdgeInsets];
    return CGSizeMake( width, height );
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[VDirectoryGroupCell nibForCell] forCellWithReuseIdentifier:[VDirectoryGroupCell suggestedReuseIdentifier]];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForIndexPath:(NSIndexPath *)indexPath withStreamItem:(VStreamItem *)streamItem
{
    NSString *identifier = [VDirectoryGroupCell suggestedReuseIdentifier];
    VDirectoryGroupCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.stream = (VStream *)streamItem;
    cell.dependencyManager = self.dependencyManager;
    cell.directoryCellFactory = self.groupedDirectoryCellFactory;
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
    return UIEdgeInsetsMake(self.groupedDirectoryCellFactory.sectionEdgeInsets.top, 0.0f, kDirectoryInset, 0.0f);
}

@end
