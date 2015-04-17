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

static CGFloat const kDirectoryInset = 10.0f;

@interface VCardDirectoryCellFactory ()

@property (nonatomic, strong) VCardDirectoryCellDecorator *cellDecorator;

@end

@implementation VCardDirectoryCellFactory

@synthesize dependencyManager;

- (instancetype)initWithDependencyManager:(VDependencyManager *)localDependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        dependencyManager = localDependencyManager;
        _cellDecorator = [[VCardDirectoryCellDecorator alloc] init];
    }
    return self;
}

- (CGSize)desiredSizeForCollectionViewBounds:(CGRect)bounds andStreamItem:(VStreamItem *)streamItem
{
    CGFloat width = CGRectGetWidth(bounds);
    UIEdgeInsets sectionEdgeInsets = [self sectionEdgeInsets];
    width -= sectionEdgeInsets.left + sectionEdgeInsets.right + [self minimumInterItemSpacing];
    width = floorf(width * 0.5f);
    
    BOOL isStreamOfStreamsRow = [VCardDirectoryCell wantsToShowStackedBackgroundForStreamItem:streamItem];
    CGFloat height = isStreamOfStreamsRow ? [VCardDirectoryCell desiredStreamOfStreamsHeightForWidth:width] : [VCardDirectoryCell desiredStreamOfContentHeightForWidth:width];
    
    return CGSizeMake(width, height);
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[VCardSeeMoreDirectoryCell nibForCell] forCellWithReuseIdentifier:[VCardSeeMoreDirectoryCell suggestedReuseIdentifier]];
    [collectionView registerNib:[VCardDirectoryCell nibForCell] forCellWithReuseIdentifier:[VCardDirectoryCell suggestedReuseIdentifier]];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForIndexPath:(NSIndexPath *)indexPath withStreamItem:(VStreamItem *)streamItem
{
    if ( streamItem == nil )
    {
        //Return the "see more" cell
        NSString *identifier = [VCardSeeMoreDirectoryCell suggestedReuseIdentifier];
        VCardSeeMoreDirectoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        [self.cellDecorator applyStyleToSeeMoreCell:cell withDependencyManager:self.dependencyManager];
        return cell;
    }
    
    NSString *identifier = [VCardDirectoryCell suggestedReuseIdentifier];
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

- (UIEdgeInsets)sectionEdgeInsets
{
    return UIEdgeInsetsMake(kDirectoryInset, kDirectoryInset, kDirectoryInset, kDirectoryInset);
}

@end