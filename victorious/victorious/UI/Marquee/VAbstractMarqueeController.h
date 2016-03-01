//
//  VAbstractMarqueeController.h
//  victorious
//
//  Created by Sharif Ahmed on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMarqueeDataDelegate.h"
#import "VMarqueeSelectionDelegate.h"
#import "VMarqueeController.h"
;
extern NSString * const VStreamURLKey;
extern NSString * const VSequenceIDKey;
extern NSString * const VSequenceIDMacro;

@class VDependencyManager, VStream, VStreamItem, VTimerManager, VUser, VAbstractMarqueeCollectionViewCell, VAbstractMarqueeStreamItemCell, Shelf;

/**
    A controller responsible for managing the content offset of the collection view, updating the collection view when marquee content changes,
        populating the stream item cells in the collection view, and relaying messages to delegates when marquee content changes or the user
        interacts with the marquee
 */
@interface VAbstractMarqueeController : NSObject <UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, VMarqueeController>

@property (nonatomic, weak) id <VMarqueeSelectionDelegate> selectionDelegate; ///< The object that should be notified of selections of marquee content
@property (nonatomic, weak) id <VMarqueeDataDelegate> dataDelegate; ///< The object that should be notified of changes in marquee content

@property (nonatomic, strong) UICollectionView *collectionView; ///< The colletion view used to display the streamItems
@property (nonatomic, strong) VStream *stream; ///< The Marquee Stream
@property (nonatomic, strong) Shelf *shelf; ///< The Marquee Shelf
@property (nonatomic, readonly) VStream *currentStream; ///< The current stream being represented by this marquee. Will return shelf or stream as appropriate.
@property (nonatomic, readonly) NSArray *marqueeItems; ///< The array of items in the marquee
@property (nonatomic, readonly) VTimerManager *autoScrollTimerManager; ///< The timer in control of auto scroll

/**
    The dependencyManager used to style the streamItem cells that are managed by this marquee controller.
        This is automatically set by the marquee collection view cell associated with this marquee controller
 */
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, readonly) NSUInteger currentPage; ///< The current page of marquee content being displayed
@property (nonatomic, readonly) CGFloat pageWidth; ///< The page width of each marquee item cell in collection view

/**
    Initializes the marquee cell factory with an instance of VDependencyManager
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/**
    Invalidates the auto-scrolling timer
 */
- (void)disableTimer;

/**
    Starts the auto-scrolling timer
 */
- (void)enableTimer;

/**
    Animates the marquee to the next item in the marquee. If on the last item in the marquee,
        animates to show the first item in the marquee
 */
- (void)selectNextTab;

/**
    Overridden by subclasses to change the fire interval of the auto-scrolling timer
 
    @return the timer interval between auto-scrolling timer firings
 */
- (NSTimeInterval)timerFireInterval;

/**
    Overridden by subclasses to respond to page changes
 
    @param currentPage The page that was just scrolled to
 */
- (void)scrolledToPage:(NSInteger)currentPage;

/**
 Spot for subclasses to override to respond to changes in marquee content, will be called after changes to the "marqueeItems" array associated with our stream
 */
- (void)marqueeItemsUpdated;

/**
 Sends visibility tracking events for current visible marquee cell
 */
- (void)updateCellVisibilityTracking;

/**
 Updates focus on marquee cells
 */
- (void)updateFocus;

/**
 End focus on marquee cells
 */
- (void)endFocusOnAllCells;

@end
