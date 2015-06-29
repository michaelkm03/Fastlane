//
//  VHashmarkView.h
//  victorious
//
//  Created by Steven F Petteruti on 6/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBaseSupplementaryView.h"
/**
 *  The view responsible for displaying hashmarkso on the trimmer control
 */
@interface VHashmarkView : VBaseSupplementaryView

+ (id)collectionReusableViewForCollectionView:(UICollectionView *)collectionView
                                 forIndexPath:(NSIndexPath *)indexPath withKind:(NSString *)kind;

@end
