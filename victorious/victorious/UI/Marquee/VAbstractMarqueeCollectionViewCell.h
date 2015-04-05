//
//  VBaseMarqueeCollectionViewCell.h
//  victorious
//
//  Created by Sharif Ahmed on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSharedCollectionReusableViewMethods.h"

@class VDependencyManager, VStreamItem, VAbstractMarqueeController;

@interface VAbstractMarqueeCollectionViewCell : UICollectionViewCell <VSharedCollectionReusableViewMethods>

/**
    Overridden by subclasses to respond to changes in marquee content. Will be deprecated after I merge with my other branch.
 */
- (void)updatedFromRefresh;

@property (nonatomic, strong) VDependencyManager *dependencyManager; ///< The dependency manager used to style this cell, the marquee controller associated with this cell and the stream item cells displayed inside this cell's collection view
@property (nonatomic, strong) VAbstractMarqueeController *marquee; ///< The marquee controller that manages the collection view displayed inside this cell
@property (nonatomic, weak, readonly) UICollectionView *collectionView; ///< The collection view displayed inside this marquee collection view cell

@end
