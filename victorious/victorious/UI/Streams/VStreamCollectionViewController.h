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
#import "VTabMenuContainedViewControllerNavigation.h"
#import "VContentViewOriginViewController.h"
#import "VNoContentView.h"

extern NSString * const VStreamCollectionViewControllerStreamURLKey; ///< The key that identifies the stream URL path in VDependencyManager
extern NSString * const VStreamCollectionViewControllerCellComponentKey; ///< A VDependencyManager key for the stream cell component

const CGFloat VStreamCollectionViewControllerCreateButtonHeight; ///< The height of the "create content" button

@class VStreamCollectionViewDataSource, VCollectionViewStreamFocusHelper;

@interface VStreamCollectionViewController : VAbstractStreamCollectionViewController <UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, VSequenceActionsDelegate, VHasManagedDependencies, VAccessoryNavigationSource, VTabMenuContainedViewControllerNavigation, VContentViewOriginViewController>

@property (nonatomic, weak) id<VSequenceActionsDelegate>actionDelegate;///<Optional param.  If this is not set, the collection view will act as the action delegate for the cells.  Use this if you are embedding this view controller somewhere (i.e. the page view controller)
@property (nonatomic, strong) VNoContentView *noContentView;///<Sets this view as the background if it cannot fetch items for the current steam.

@property (nonatomic, assign) BOOL canShowMarquee; ///< Defaults to YES; if NO, we won't adjust the "hasHeaderCell" variable even when a marquee is available in the stream

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

/**
 Allows a context that instantiates a VUserProfileViewController to provide a class (possibly itself)
 used to override behavior of template-driven view tracking.
 @see VDependencyManager+VTracking
 */
@property (nonatomic, assign) Class viewTrackingClassOverride;

@end

#pragma mark - 

@interface VDependencyManager (VStreamCollectionViewController)

/**
 Returns a stream of memes for the given sequence.
 */
- (VStreamCollectionViewController *)memeStreamForSequence:(VSequence *)sequence;

/**
 Returns a stream of gifs for the given sequence.
 */
- (VStreamCollectionViewController *)gifStreamForSequence:(VSequence *)sequence;

@end
