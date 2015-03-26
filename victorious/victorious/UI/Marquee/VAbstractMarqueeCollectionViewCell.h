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

- (void)updatedFromRefresh;

- (void)restartAutoScroll;

@property (nonatomic, readonly) UIImageView *currentPreviewImageView;
@property (nonatomic, readonly) VStreamItem *currentItem;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VAbstractMarqueeController *marquee;
@property (nonatomic, weak, readonly) UICollectionView *collectionView;

@end
