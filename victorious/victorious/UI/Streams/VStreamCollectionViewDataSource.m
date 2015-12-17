//
//  VStreamCollectionViewDataSource.m
//  victorious
//
//  Created by Will Long on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCollectionViewDataSource.h"
#import "VCardDirectoryCell.h"
#import "VFooterActivityIndicatorView.h"
#import "VPaginationManager.h"
#import "VStream+Fetcher.h"
#import "VStreamItem+Fetcher.h"
#import "VSequence.h"
#import "CHTCollectionViewWaterfallLayout+ColumnAccessor.h"
#import "victorious-Swift.h"
#import <KVOController/FBKVOController.h>

NSString *const VStreamCollectionDataSourceDidChangeNotification = @"VStreamCollectionDataSourceDidChangeNotification";

@implementation VStreamCollectionViewDataSource

- (instancetype)initWithStream:(VStream *)stream
{
    self = [self init];
    if ( self != nil )
    {
        _visibleStreamItems = [[NSOrderedSet alloc] init];
        self.stream = stream;
    }
    return self;
}

- (void)setSuppressShelves:(BOOL)suppressShelves
{
    if ( _suppressShelves == suppressShelves )
    {
        return;
    }
    _suppressShelves = suppressShelves;
    self.visibleStreamItems = _visibleStreamItems;
}

- (void)setVisibleStreamItems:(NSOrderedSet *)visibleStreamItems
{
    if ( self.suppressShelves )
    {
        _visibleStreamItems = [self streamItemsWithoutShelvesFromStreamItems:visibleStreamItems];
    }
    else
    {
        _visibleStreamItems = visibleStreamItems;
    }
}

- (NSOrderedSet *)streamItemsWithoutShelvesFromStreamItems:(NSOrderedSet *)streamItems
{
    NSPredicate *streamRemovalPredicate = [NSPredicate predicateWithBlock:^BOOL(VStreamItem *streamItem, NSDictionary *bindings)
    {
        return ![streamItem.itemType isEqualToString:VStreamItemTypeShelf];
    }];
    return [[NSOrderedSet alloc] initWithArray:[streamItems.array filteredArrayUsingPredicate:streamRemovalPredicate]];
}

- (VStreamItem *)itemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.count || self.count <= (NSUInteger)indexPath.row)
    {
        return nil;
    }
    
    return [self.visibleStreamItems objectAtIndex:indexPath.row];
}

- (NSIndexPath *)indexPathForItem:(VStreamItem *)streamItem
{
    NSInteger section = self.hasHeaderCell ? 1 : 0;
    NSUInteger index = [self.visibleStreamItems indexOfObject:streamItem];
    return [NSIndexPath indexPathForItem:(NSInteger)index inSection:section];
}

- (void)removeStreamItem:(VStreamItem *)streamItem
{
#warning Create RequestOperation for this
    NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.stream.streamItems];
    [tempSet removeObject:streamItem];
    self.stream.streamItems = tempSet;
}

- (NSUInteger)count
{
    return self.visibleStreamItems.count;
}

- (void)unloadStream
{
    id<PersistentStoreTypeBasic>  persistentStore = [[MainPersistentStore alloc] init];
    [persistentStore syncBasic:^void(id<PersistentStoreContextBasic> context) {
        self.stream.streamItems = [[NSOrderedSet alloc] init];
        self.stream.marqueeItems = [[NSOrderedSet alloc] init];
        [context saveChanges];
    }];
}

- (NSInteger)sectionIndexForContent
{
    if ( self.hasHeaderCell )
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

- (void)setHasHeaderCell:(BOOL)hasHeaderCell
{
    if ( hasHeaderCell == _hasHeaderCell )
    {
        return;
    }
    _hasHeaderCell = hasHeaderCell;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ( [self.delegate respondsToSelector:@selector(dataSource:numberOfRowsInSection:)] )
    {
        return [self.delegate dataSource:self numberOfRowsInSection:section];
    }
    
    if (self.hasHeaderCell && section == 0)
    {
        return 1;
    }
    
    return [self count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.delegate dataSource:self cellForIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if ( [self.delegate respondsToSelector:@selector(numberOfSectionsForDataSource:)] )
    {
        return [self.delegate numberOfSectionsForDataSource:self];
    }
    
    if (self.hasHeaderCell)
    {
        return 2;
    }
    return 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    BOOL isFooter = kind == UICollectionElementKindSectionFooter || kind == CHTCollectionElementKindSectionFooter;
    if ( isFooter && [self.delegate shouldDisplayActivityViewFooterForCollectionView:collectionView inSection:indexPath.section] )
    {
        return [self.collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                       withReuseIdentifier:[VFooterActivityIndicatorView reuseIdentifier]
                                                              forIndexPath:indexPath];
    }
    else if ( [self.delegate respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)] )
    {
        return [(id <UICollectionViewDataSource>)self.delegate collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    }
    
    return nil;
}

@end
