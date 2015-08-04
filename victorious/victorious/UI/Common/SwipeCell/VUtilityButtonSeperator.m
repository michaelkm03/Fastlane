//
//  VUtilityButtonSeperator.m
//  
//
//  Created by Steven F Petteruti on 8/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VUtilityButtonSeperator.h"

@implementation VUtilityButtonSeperator

+ (id)collectionReusableViewForCollectionView:(UICollectionView *)collectionView
                                      fromNib:(UINib *)nib
                                 forIndexPath:(NSIndexPath *)indexPath
                                     withKind:(NSString *)kind
{
    NSString *cellIdentifier = [self suggestedReuseIdentifier];
    VUtilityButtonSeperator *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    return cell;
}

+ (id)collectionReusableViewForCollectionView:(UICollectionView *)collectionView
                                 forIndexPath:(NSIndexPath *)indexPath withKind:(NSString *)kind
{
    return [[self class] collectionReusableViewForCollectionView:collectionView
                                                         fromNib:[self nibForCell]
                                                    forIndexPath:indexPath
                                                        withKind:kind];
}

@end
