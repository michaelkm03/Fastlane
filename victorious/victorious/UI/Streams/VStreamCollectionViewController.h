//
//  VStreamCollectionViewController.h
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VAbstractStreamCollectionViewController.h"
#import "VDependencyManager.h"
#import "VHasManagedDependencies.h"
#import "VSequenceActionsDelegate.h"
#import "VNewContentViewController.h"
#import "VAccessoryNavigationSource.h"
#import "VContentViewOriginViewController.h"
#import "VNoContentView.h"

extern NSString * const VStreamCollectionViewControllerStreamURLKey; ///< The key that identifies the stream URL path in VDependencyManager
extern NSString * const VStreamCollectionViewControllerCellComponentKey; ///< A VDependencyManager key for the stream cell component

const CGFloat VStreamCollectionViewControllerCreateButtonHeight; ///< The height of the "create content" button

@class VStreamCollectionViewDataSource, VCollectionViewStreamFocusHelper, VUploadProgressViewController;

@interface VStreamCollectionViewController : VAbstractStreamCollectionViewController <UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, VSequenceActionsDelegate, VHasManagedDependencies, VAccessoryNavigationSource, VContentViewOriginViewController>

@property (nonatomic, weak) id<VSequenceActionsDelegate>actionDelegate;///<Optional param.  If this is not set, the collection view will act as the action delegate for the cells.  Use this if you are embedding this view controller somewhere (i.e. the page view controller)
@property (nonatomic, strong) VNoContentView *noContentView;///<Sets this view as the background if it cannot fetch items for the current steam.

@property (nonatomic, assign) BOOL suppressShelves; ///< Default to NO. When YES, shelves from the stream will not be displayed.

/**
 *  Creates a new stream collection view controller
 *
 *  @param stream The stream to display
 */
+ (instancetype)streamViewControllerForStream:(VStream *)stream;

- (void)showHashtagStreamWithHashtag:(NSString *)hashtag;

- (void)navigateToStream:(VStream *)stream atStreamItem:(VStreamItem *)streamItem;

/**
 *  For tracking purposes, each cell will only count as having been viewed if the ratio of its
 *  visible area is greater than or equal to this value.
 */
@property (nonatomic, assign) float trackingMinRequiredCellVisibilityRatio;

/**
 *  The sequence action controller that will respond to actions taken on sequences
 *  represented by cells within this collection view controller.
 */
@property (readonly, nonatomic) VSequenceActionController *sequenceActionController;

/**
 Exposed for Swift.  Don't touch unless you know what you're doing :)
 */
@property (nonatomic, strong) VCollectionViewStreamFocusHelper *focusHelper;

@property (nonatomic, strong, readwrite) NSString *sourceScreenName;

@property (strong, nonatomic) VUploadProgressViewController *uploadProgressViewController;

@end
