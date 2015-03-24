//
//  VStreamCollectionViewController.h
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VAbstractStreamCollectionViewController.h"
#import "VHasManagedDependencies.h"
#import "VSequenceActionsDelegate.h"
#import "VNewContentViewController.h"

extern NSString * const VStreamCollectionViewControllerStreamURLKey; ///< The key that identifies the stream URL path in VDependencyManager
extern NSString * const VStreamCollectionViewControllerCreateSequenceIconKey; ///< The key that identifies the create sequence icon in VDependencyManager
extern NSString * const VStreamCollectionViewControllerCellComponentKey; ///< A VDependencyManager key for the stream cell component

const CGFloat VStreamCollectionViewControllerCreateButtonHeight; ///< The height of the "create content" button

@class VStreamCollectionViewDataSource;

@interface VStreamCollectionViewController : VAbstractStreamCollectionViewController <UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, VSequenceActionsDelegate, VHasManagedDependancies>

@property (nonatomic, weak) id<VSequenceActionsDelegate>actionDelegate;///<Optional param.  If this is not set, the collection view will act as the action delegate for the cells.  Use this if you are embedding this view controller somewhere (i.e. the page view controller)
@property (nonatomic) BOOL shouldDisplayMarquee;
@property (nonatomic, strong) UIView *noContentView;///<Sets this view as the background if it cannot fetch items for the current steam.
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, assign) BOOL canShowContent; // Defaults to YES

/**
 *  Creates a new stream collection view controller
 *
 *  @param stream The stream to display
 */
+ (instancetype)streamViewControllerForStream:(VStream *)stream;

/**
 *  For tracking purposes, each cell will only count as having been viewed if the ratio of its
 *  visible area is greater than or equal to this value.
 */
@property (nonatomic, assign) float trackingMinRequiredCellVisibilityRatio;

@end
