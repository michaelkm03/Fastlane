//
//  VTimeMarkView.h
//  victorious
//
//  Created by Steven F Petteruti on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBaseSupplementaryView.h"
/**
 *  The view responsible for displaying timemarks on the trimmer control
 */
@interface VTimeMarkView : VBaseSupplementaryView

@property (nonatomic, strong) UILabel *timeLabel;

+ (id)collectionReusableViewForCollectionView:(UICollectionView *)collectionView
                                 forIndexPath:(NSIndexPath *)indexPath withKind:(NSString *)kind;

@end
