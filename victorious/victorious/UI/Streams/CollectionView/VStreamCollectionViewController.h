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

@class VStreamCollectionViewDataSource, VHashtag;

@interface VStreamCollectionViewController : VAbstractStreamCollectionViewController <VNewContentViewControllerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, VSequenceActionsDelegate, VHasManagedDependancies>

@property (nonatomic, weak) id<VSequenceActionsDelegate>actionDelegate;///<Optional param.  If this is not set, the collection view will act as the action delegate for the cells.  Use this if you are embedding this view controller somewhere (i.e. the page view controller)
@property (nonatomic) BOOL shouldDisplayMarquee;
@property (nonatomic, strong) UIView *noContentView;///<Sets this view as the background if it cannot fetch items for the current steam.

+ (instancetype)homeStreamCollection;
+ (instancetype)communityStreamCollection;
+ (instancetype)ownerStreamCollection;
+ (instancetype)hashtagStreamWithHashtag:(NSString *)hashtag;

/**
 *  Returns a stream collection view controller with a victorious themed nav header.
 *
 *  @param stream     The first stream to display
 *  @param allStreams All streams for the view (the order will be used for the nav header)
 *  @param title      The title to use on the nav header.
 */
+ (instancetype)streamViewControllerForDefaultStream:(VStream *)stream andAllStreams:(NSArray *)allStreams title:(NSString *)title;

/**
 *  Returns a stream collection view control.  This method does not add a nav header to the VC.
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
