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
#import "VStreamItem+Fetcher.h"
#import "VSequence.h"
#import "victorious-Swift.h"

@implementation VStreamCollectionViewDataSource

- (instancetype)init
{
    NSAssert( NO, @"VStreamCollectionViewDataSource must be instantiated using the designated initializer that contains a `VStream` argument" );
    return nil;
}

- (instancetype)initWithStream:(VStream *)stream
{
    self = [super init];
    if ( self != nil )
    {
        _stream = stream;
        _paginatedDataSource = [[PaginatedDataSource alloc] init];
        _visibleItems = [[NSOrderedSet alloc] init];
    }
    return self;
}

- (BOOL)isLoading
{
    return self.paginatedDataSource.isLoading;
}

- (VStreamItem *)itemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.count || self.count <= (NSUInteger)indexPath.row)
    {
        return nil;
    }
    
    return [self.visibleItems objectAtIndex:indexPath.row];
}

- (NSIndexPath *)indexPathForItem:(VStreamItem *)streamItem
{
    NSInteger section = self.hasHeaderCell ? 1 : 0;
    NSUInteger index = [self.visibleItems indexOfObject:streamItem];
    return [NSIndexPath indexPathForItem:(NSInteger)index inSection:section];
}

- (NSUInteger)count
{
    return self.visibleItems.count;
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    BOOL isFooter = kind == UICollectionElementKindSectionFooter;
    if ( isFooter && [self.delegate shouldDisplayActivityViewFooterForCollectionView:collectionView inSection:indexPath.section] )
    {
        return [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                       withReuseIdentifier:[VFooterActivityIndicatorView reuseIdentifier]
                                                              forIndexPath:indexPath];
    }
    else if ( [self.delegate respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)] )
    {
        return [(id <UICollectionViewDataSource>)self.delegate collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    }
    
    //In case none of the above cases executed, and to prevent crash
    NSString *failureReusableIdentifier = @"failureReusableViewIdentifier";
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:kind withReuseIdentifier:failureReusableIdentifier];
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:failureReusableIdentifier forIndexPath:indexPath];
}

@end
