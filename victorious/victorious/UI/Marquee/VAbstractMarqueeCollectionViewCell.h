//
//  VAbstractMarqueeCollectionViewCell.h
//  victorious
//
//  Created by Sharif Ahmed on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSharedCollectionReusableViewMethods.h"
#import "VMarqueeDataDelegate.h"
#import "VParallaxScrolling.h"
#import "VFocusable.h"

NS_ASSUME_NONNULL_BEGIN

@class VDependencyManager, VStreamItem, VAbstractMarqueeController;

/**
    A collection view cell that contains the collectionView that displays marquee content and any views
        that are displayed across all marquee stream item cells
 */
@interface VAbstractMarqueeCollectionViewCell : UICollectionViewCell <VSharedCollectionReusableViewMethods, VParallaxScrolling, VFocusable>

/**
 The dependency manager used to style this cell, the marquee controller associated with this cell and
    the stream item cells displayed inside this cell's collection view
 */
@property (nonatomic, strong, nullable) VDependencyManager *dependencyManager;
@property (nonatomic, strong, nullable) VAbstractMarqueeController *marquee; ///< The marquee controller that manages the collection view displayed inside this cell
@property (nonatomic, weak, readonly) UICollectionView *marqueeCollectionView; ///< The collection view displayed inside this marquee collection view cell

@end

NS_ASSUME_NONNULL_END
