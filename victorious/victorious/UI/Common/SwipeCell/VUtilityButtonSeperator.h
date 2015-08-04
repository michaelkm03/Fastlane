//
//  VUtilityButtonSeperator.h
//  
//
//  Created by Steven F Petteruti on 8/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBaseSupplementaryView.h"

/*
 *  The seperator view to be displayed between utility buttons in the swipable
 *  comment cell
 */
@interface VUtilityButtonSeperator : VBaseSupplementaryView

/*
 *  Override for returning the VUtilityButtonSeperator view for the collectionview
 */
+ (id)collectionReusableViewForCollectionView:(UICollectionView *)collectionView
                                 forIndexPath:(NSIndexPath *)indexPath withKind:(NSString *)kind;

@end
