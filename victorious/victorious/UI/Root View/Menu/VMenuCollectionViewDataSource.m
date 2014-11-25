//
//  VMenuCollectionViewDataSource.m
//  victorious
//
//  Created by Josh Hinman on 11/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMenuCollectionViewDataSource.h"
#import "VNavigationMenuItem.h"
#import "VNavigationMenuItemCell.h"
#import "VProvidesNavigationMenuItemBadge.h"

@interface VMenuCollectionViewDataSource ()

@property (nonatomic, weak) UICollectionView *collectionView;

@end

@implementation VMenuCollectionViewDataSource

- (instancetype)initWithCellReuseID:(NSString *)cellReuseID sectionsOfMenuItems:(NSArray *)menuSections
{
    self = [super init];
    if (self)
    {
        _cellReuseID = [cellReuseID copy];
        _menuSections = [menuSections copy];
        _badgeTotal = [self calculateBadgeTotal];
        [self setBadgeUpdateBlocks];
    }
    return self;
}

- (VNavigationMenuItem *)menuItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert((NSUInteger)indexPath.section < self.menuSections.count, @"Invalid section specified");
    NSArray *section = self.menuSections[indexPath.section];
    NSAssert((NSUInteger)indexPath.item < section.count, @"Invalid item specified");
    return section[indexPath.item];
}

#pragma mark - Badge Numbers

- (NSInteger)calculateBadgeTotal
{
    NSInteger total = 0;
    for (NSArray *section in self.menuSections)
    {
        if ([section isKindOfClass:[NSArray class]])
        {
            for (VNavigationMenuItem *menuItem in section)
            {
                if ([menuItem isKindOfClass:[VNavigationMenuItem class]])
                {
                    id destination = menuItem.destination;
                    if ([destination respondsToSelector:@selector(badgeNumber)])
                    {
                        total += [destination badgeNumber];
                    }
                }
            }
        }
    }
    return total;
}

- (void)setBadgeUpdateBlocks
{
    [self.menuSections enumerateObjectsUsingBlock:^(NSArray *section, NSUInteger sectionIndex, BOOL *stop)
    {
        if ( ![section isKindOfClass:[NSArray class]] )
        {
            return;
        }
        [section enumerateObjectsUsingBlock:^(VNavigationMenuItem *menuItem, NSUInteger itemIndex, BOOL *stop)
        {
            if ( ![menuItem isKindOfClass:[VNavigationMenuItem class]] )
            {
                return;
            }
            id destination = menuItem.destination;
            
            if ([destination respondsToSelector:@selector(setBadgeNumberUpdateBlock:)])
            {
                __typeof(self) __weak weakSelf = self;
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
                [destination setBadgeNumberUpdateBlock:^(NSInteger badgeNumber)
                {
                    __typeof(weakSelf) strongSelf = weakSelf;
                    
                    if (strongSelf != nil)
                    {
                        id cell = [strongSelf.collectionView cellForItemAtIndexPath:indexPath];
                        if ([cell respondsToSelector:@selector(setBadgeNumber:)])
                        {
                            [cell setBadgeNumber:badgeNumber];
                        }
                        self.badgeTotal = [strongSelf calculateBadgeTotal];
                    }
                }];
            }
        }];
    }];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return (NSInteger)self.menuSections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSParameterAssert((NSUInteger)section < self.menuSections.count);
    NSArray *menuSection = self.menuSections[section];
    return (NSInteger)menuSection.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.collectionView = collectionView;
    id cell = (UICollectionViewCell<VNavigationMenuItemCell> *)[collectionView dequeueReusableCellWithReuseIdentifier:self.cellReuseID
                                                                                                         forIndexPath:indexPath];
    VNavigationMenuItem *menuItem = [self menuItemAtIndexPath:indexPath];
    
    if ([cell respondsToSelector:@selector(setNavigationMenuItem:)])
    {
        [cell setNavigationMenuItem:menuItem];
    }
    
    if ([cell respondsToSelector:@selector(setBadgeNumber:)] && [menuItem.destination respondsToSelector:@selector(badgeNumber)])
    {
        [cell setBadgeNumber:[menuItem.destination badgeNumber]];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        if (self.sectionHeaderReuseID != nil)
        {
            return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:self.sectionHeaderReuseID forIndexPath:indexPath];
        }
    }
    else if ([kind isEqualToString:UICollectionElementKindSectionFooter])
    {
        if (self.sectionFooterReuseID != nil)
        {
            return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:self.sectionFooterReuseID forIndexPath:indexPath];
        }
    }
    return nil;
}

@end
