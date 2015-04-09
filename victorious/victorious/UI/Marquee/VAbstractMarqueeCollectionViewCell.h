//
//  VBaseMarqueeCollectionViewCell.h
//  victorious
//
//  Created by Sharif Ahmed on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSharedCollectionReusableViewMethods.h"
#import "VMarqueeDataDelegate.h"

@class VDependencyManager, VStreamItem, VAbstractMarqueeController;

@interface VAbstractMarqueeCollectionViewCell : UICollectionViewCell <VSharedCollectionReusableViewMethods>

/**
 The dependency manager used to style this cell, the marquee controller associated with this cell and
    the stream item cells displayed inside this cell's collection view
 */
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VAbstractMarqueeController *marquee; ///< The marquee controller that manages the collection view displayed inside this cell
@property (nonatomic, weak, readonly) UICollectionView *marqueeCollectionView; ///< The collection view displayed inside this marquee collection view cell

@end
