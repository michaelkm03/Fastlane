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
 *  The view responsible for displaying hashmarks on the trimmer control
 */
@interface VHashmarkView : VBaseSupplementaryView

/**
 *  Override for returning the supplmentary view for the collectionview
 *
 *  @param collectionView The collectionview wherein the hashmark view is to be displayed
 *  @param indexPath The indexpath for the hashmark view
 *  @param kind The kind of supplementary view for the hashmark view
 */
+ (id)collectionReusableViewForCollectionView:(UICollectionView *)collectionView
                                 forIndexPath:(NSIndexPath *)indexPath withKind:(NSString *)kind;

@end
