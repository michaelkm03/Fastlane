//
//  VCardDirectoryCellFactory.m
//  victorious
//
//  Created by Sharif Ahmed on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCardDirectoryCellFactory.h"
#import "VDependencyManager.h"
#import "VCardDirectoryCell.h"
#import "VCardSeeMoreDirectoryCell.h"
#import "VCardDirectoryCellDecorator.h"
#import "VStream.h"
#import "VCardDirectoryCollectionViewFlowLayout.h"
#import "VCompatibility.h"

static CGFloat const kDirectoryInset = 10.0f;

@interface VCardDirectoryCellFactory ()

@property (nonatomic, strong) VCardDirectoryCellDecorator *cellDecorator;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VCardDirectoryCellFactory

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
        _cellDecorator = [[VCardDirectoryCellDecorator alloc] init];
    }
    return self;
}

- (VDirectoryCollectionFlowLayout *)collectionViewFlowLayout
{
    return [[VCardDirectoryCollectionViewFlowLayout alloc] init];
}

- (CGSize)sizeWithCollectionViewBounds:(CGRect)bounds ofCellForStreamItem:(VStreamItem *)streamItem
{
    CGFloat width = CGRectGetWidth(bounds);
    UIEdgeInsets sectionEdgeInsets = [self sectionInsets];
    width -= sectionEdgeInsets.left + sectionEdgeInsets.right + [self minimumInterItemSpacing];
    width = VFLOOR(width * 0.5f);
    
    BOOL isStreamOfStreamsRow = [VCardDirectoryCell wantsToShowStackedBackgroundForStreamItem:streamItem];
    CGFloat height = isStreamOfStreamsRow ? [VCardDirectoryCell desiredStreamOfStreamsHeightForWidth:width] : [VCardDirectoryCell desiredStreamOfContentHeightForWidth:width];
    
    return CGSizeMake(width, height);
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    NSAssert(NO, @"Call the 'withStreamItems' version of this function instead");
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView withStreamItems:(NSArray *)streamItems
{
    for ( VStreamItem *streamItem in streamItems )
    {
        NSString *identifier = [VCardDirectoryCell reuseIdentifierForStreamItem:streamItem baseIdentifier:nil dependencyManager:self.dependencyManager];
        [collectionView registerNib:[VCardDirectoryCell nibForCell] forCellWithReuseIdentifier:identifier];
    }
    [collectionView registerNib:[VCardSeeMoreDirectoryCell nibForCell] forCellWithReuseIdentifier:[VCardSeeMoreDirectoryCell suggestedReuseIdentifier]];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForStreamItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)indexPath
{
    if ( streamItem == nil )
    {
        //Return the "see more" cell
        NSString *identifier = [VCardSeeMoreDirectoryCell suggestedReuseIdentifier];
        VCardSeeMoreDirectoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        [self.cellDecorator applyStyleToSeeMoreCell:cell withDependencyManager:self.dependencyManager];
        return cell;
    }
    
    NSString *identifier = [VCardDirectoryCell reuseIdentifierForStreamItem:streamItem baseIdentifier:nil dependencyManager:self.dependencyManager];
    VCardDirectoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [self.cellDecorator populateCell:cell withStreamItem:streamItem];
    [self.cellDecorator applyStyleToCell:cell withDependencyManager:self.dependencyManager];
    return cell;
}

- (CGFloat)minimumInterItemSpacing
{
    return kDirectoryInset;
}

- (CGFloat)minimumLineSpacing
{
    return kDirectoryInset;
}

- (UIEdgeInsets)sectionInsets
{
    return UIEdgeInsetsMake(kDirectoryInset, kDirectoryInset, kDirectoryInset, kDirectoryInset);
}

@end
