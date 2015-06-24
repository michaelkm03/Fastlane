//
//  VTimeMarkView.h
//  victorious
//
//  Created by Steven F Petteruti on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VTimeMarkView : UICollectionReusableView

@property (nonatomic, strong) UILabel *timeLabel;

+ (NSString *)cellIdentifier;
+ (id)collectionReusableViewForCollectionView:(UICollectionView *)collectionView
                                      fromNib:(UINib *)nib
                                 forIndexPath:(NSIndexPath *)indexPath
                                     withKind:(NSString *)kind;

+ (id)collectionReusableViewForCollectionView:(UICollectionView *)collectionView
                                 forIndexPath:(NSIndexPath *)indexPath withKind:(NSString *)kind;

+ (UINib *)nib;

@end
