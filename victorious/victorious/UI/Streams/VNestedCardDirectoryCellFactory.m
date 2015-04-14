//
//  VNestedCardDirectoryCellFactory.m
//  victorious
//
//  Created by Sharif Ahmed on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VNestedCardDirectoryCellFactory.h"
#import "VDirectoryItemCell.h"
#import "VDirectorySeeMoreItemCell.h"
#import "VShowcaseCellFactory.h"
#import "VDirectoryCellDecorator.h"
#import "VStreamItem+Fetcher.h"
#import "VDependencyManager.h"
#import "VStream.h"

static CGFloat const kStreamDirectoryGroupCellBaseWidth = 320.0f;
static CGFloat const kStreamSubdirectoryItemCellBaseWidth = 140.0f;
static CGFloat const kStreamSubdirectoryItemCellBaseHeight = 206.0f;
static CGFloat const kStreamDirectoryGroupCellInset = 10.0f; //Must be >= 1.0f

@interface VNestedCardDirectoryCellFactory ()

@property (nonatomic, strong) UICollectionViewLayout *collectionViewLayout;
@property (nonatomic, strong) VDirectoryCellDecorator *cellDecorator;

@end

@implementation VNestedCardDirectoryCellFactory

@synthesize dependencyManager;

- (instancetype)initWithDependencyManager:(VDependencyManager *)localDependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        dependencyManager = localDependencyManager;
        _cellDecorator = [[VDirectoryCellDecorator alloc] init];
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
    CGFloat boundsWidth = CGRectGetWidth(bounds);
    CGFloat height = [self directoryCellHeightForBoundsWidth:boundsWidth];
    CGFloat width = [self directoryCellWidthForBoundsWidth:boundsWidth];
    return CGSizeMake(width, height);
}

- (CGSize)desiredSizeForCollectionViewBounds:(CGRect)bounds streamItem:(VStreamItem *)streamItem inStreamOfStreamsRow:(BOOL)streamOfStreamsRow
{
    CGSize desiredSize = [self desiredSizeForCollectionViewBounds:bounds andStreamItem:streamItem];
    if ( streamOfStreamsRow )
    {
        desiredSize.height += VDirectoryItemStackHeight;
    }
    return desiredSize;
}

- (CGFloat)directoryCellHeightForBoundsWidth:(CGFloat)width
{
    CGFloat multiplicant = width / kStreamDirectoryGroupCellBaseWidth;
    return ( kStreamSubdirectoryItemCellBaseHeight * multiplicant );
}

- (CGFloat)directoryCellWidthForBoundsWidth:(CGFloat)width
{
    return ( width / kStreamDirectoryGroupCellBaseWidth ) * kStreamSubdirectoryItemCellBaseWidth;
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[VDirectoryItemCell nibForCell] forCellWithReuseIdentifier:[VDirectoryItemCell suggestedReuseIdentifier]];
    [collectionView registerNib:[VDirectorySeeMoreItemCell nibForCell] forCellWithReuseIdentifier:[VDirectorySeeMoreItemCell suggestedReuseIdentifier]];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForIndexPath:(NSIndexPath *)indexPath withStreamItem:(VStreamItem *)streamItem
{
    if ( streamItem != nil )
    {
        //Populate streamItem from item in stream instead of top-level stream item
        NSString *identifier = [VDirectoryItemCell suggestedReuseIdentifier];
        VDirectoryItemCell *directoryCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                           forIndexPath:indexPath];
        [self.cellDecorator populateCell:directoryCell withStreamItem:streamItem];
        [self.cellDecorator applyStyleToCell:directoryCell withDependencyManager:self.dependencyManager];
        [self.cellDecorator highlightTagsInCell:directoryCell withTagColor:[self.dependencyManager colorForKey:VDependencyManagerLinkColorKey]];
        
        return directoryCell;
    }
    else
    {
        //Nil streamItem implies the see more cell should be returned
        NSString *identifier = [VDirectorySeeMoreItemCell suggestedReuseIdentifier];
        VDirectorySeeMoreItemCell *seeMoreCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
        [self.cellDecorator applyStyleToSeeMoreCell:seeMoreCell withDependencyManager:self.dependencyManager];
        
        return seeMoreCell;
    }
}

- (CGFloat)minimumInterItemSpacing
{
    return kStreamDirectoryGroupCellInset;
}

- (CGFloat)minimumLineSpacing
{
    return 0.0f;
}

- (UIEdgeInsets)sectionEdgeInsets
{
    return UIEdgeInsetsMake(0.0f,
                            kStreamDirectoryGroupCellInset,
                            kStreamDirectoryGroupCellInset,
                            kStreamDirectoryGroupCellInset);
}

@end
