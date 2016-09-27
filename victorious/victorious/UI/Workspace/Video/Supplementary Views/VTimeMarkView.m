//
//  VTimeMarkView.m
//  victorious
//
//  Created by Steven F Petteruti on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTimeMarkView.h"

@implementation VTimeMarkView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.timeLabel.text  = @"00:00";
    self.timeLabel.textColor = [UIColor lightGrayColor];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.timeLabel];
}

+ (id)collectionReusableViewForCollectionView:(UICollectionView *)collectionView
                                      fromNib:(UINib *)nib
                                 forIndexPath:(NSIndexPath *)indexPath
                                     withKind:(NSString *)kind
{
    NSString *cellIdentifier = [self suggestedReuseIdentifier];
    VTimeMarkView *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:cellIdentifier forIndexPath:indexPath];
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
