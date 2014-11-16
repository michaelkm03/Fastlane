//
//  VMenuCollectionViewDataSource.m
//  victorious
//
//  Created by Josh Hinman on 11/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMenuCollectionViewDataSource.h"
#import "VNavigationMenuItemCell.h"

@implementation VMenuCollectionViewDataSource

- (instancetype)initWithCellReuseID:(NSString *)cellReuseID sectionsOfMenuItems:(NSArray *)menuSections
{
    self = [super init];
    if (self)
    {
        _cellReuseID = [cellReuseID copy];
        _menuSections = [menuSections copy];
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
    id cell = (UICollectionViewCell<VNavigationMenuItemCell> *)[collectionView dequeueReusableCellWithReuseIdentifier:self.cellReuseID
                                                                                                                                                     forIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(setNavigationMenuItem:)])
    {
        [cell setNavigationMenuItem:[self menuItemAtIndexPath:indexPath]];
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
