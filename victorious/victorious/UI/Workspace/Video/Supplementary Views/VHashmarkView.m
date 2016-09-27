//
//  VHashmarkView.m
//  victorious
//
//  Created by Steven F Petteruti on 6/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHashmarkView.h"

@implementation VHashmarkView

- (void)awakeFromNib
{
    [super awakeFromNib];
    UIView *hash = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 3, 15)];
    hash.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:hash];
}

+ (id)collectionReusableViewForCollectionView:(UICollectionView *)collectionView
                                      fromNib:(UINib *)nib
                                 forIndexPath:(NSIndexPath *)indexPath
                                     withKind:(NSString *)kind
{
    NSString *cellIdentifier = [self suggestedReuseIdentifier];
    VHashmarkView *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:cellIdentifier forIndexPath:indexPath];
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
