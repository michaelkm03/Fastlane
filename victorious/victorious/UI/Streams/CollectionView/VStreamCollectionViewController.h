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

@class VStreamCollectionViewDataSource;

@interface VStreamCollectionViewController : VAbstractStreamCollectionViewController <VNewContentViewControllerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, VSequenceActionsDelegate, VHasManagedDependancies>

@property (nonatomic, weak) id<VSequenceActionsDelegate>actionDelegate;///<Optional param.  If this is not set, the collection view will act as the action delegate for the cells.  Use this if you are embedding this view controller somewhere (i.e. the page view controller)
@property (nonatomic) BOOL shouldDisplayMarquee;
@property (nonatomic, strong) UIView *noContentView;///<Sets this view as the background if it cannot fetch items for the current steam.

/**
 *  Creates a new stream collection view controller
 *
 *  @param stream The stream to display
 */
+ (instancetype)streamViewControllerForStream:(VStream *)stream;

@end
