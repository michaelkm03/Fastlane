//
//  VBaseMarqueeController.h
//  victorious
//
//  Created by Sharif Ahmed on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VStreamCollectionViewDataSource.h"
#import "VMarqueeControllerDelegate.h"

extern NSString * const kMarqueeURLKey;

@class VDependencyManager, VStream, VStreamItem, VStreamCollectionViewDataSource, VTimerManager, VUser, VAbstractMarqueeController, VAbstractMarqueeCollectionViewCell;

@interface VAbstractMarqueeController : NSObject <VStreamCollectionDataDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) id <VMarqueeControllerDelegate> delegate; ///< The delegate that will respond to changes in marquee content and selections of marquee content. Will be deprecated after I merge with my other branch.
@property (nonatomic, strong) UICollectionView *collectionView; ///< The colletion view used to display the streamItems
@property (nonatomic, readonly) VStreamItem *currentStreamItem; ///< The stream item currently being displayed
@property (nonatomic, readonly) VStream *stream; ///< The Marquee Stream
@property (nonatomic, readonly) VStreamCollectionViewDataSource *streamDataSource; ///<The VStreamCollectionViewDataSource for the object.
@property (nonatomic, readonly) VTimerManager *autoScrollTimerManager; ///< The timer in control of auto scroll
@property (nonatomic, strong) VDependencyManager *dependencyManager; ///< The dependencyManager used to style the streamItem cells that are managed by this marquee controller. This is automatically set by the marquee collection view cell associated with this marquee controller
@property (nonatomic, readonly) NSInteger currentPage; ///< The current page of marquee content being displayed

/**
 Initializes the marquee cell factory with an instance of VDependencyManager
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager NS_DESIGNATED_INITIALIZER;

/**
 Sends -registerClass:forCellWithReuseIdentifier: and -registerNib:forCellWithReuseIdentifier:
 messages to the collection view. Should be called as soon as the collection view is
 initialized.
 */
- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView;

/**
 Returns a configured marquee cell. This MUST be overridden by subclasses
 */
- (VAbstractMarqueeCollectionViewCell *)marqueeCellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath;

/**
    Invalidates the auto-scrolling timer
 */
- (void)disableTimer;

/**
    Starts the auto-scrolling timer
 */
- (void)enableTimer;

/**
    Animates the marquee to the next item in the marquee. If on the last item in the marquee, animates to show the first item in the marquee
 */
- (void)selectNextTab;

/**
    Refreshes the content that is being managed by this marqueeController and calls the success and failure blocks as appropriate
 
    @param successBlock A block that will be called on the successful refresh of content in the stream that's managed by this marquee controller
    @param failureBlock A block that will be called when the marquee controller fails to refresh the content of the stream it is managing
 */
- (void)refreshWithSuccess:(void (^)(void))successBlock failure:(void (^)(NSError *))failureBlock;

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
    Overridden by subclasses to provide the reuse identifier that will be used to register cells with the collection view managed by this marquee controller. In most instances, subclasses should just return the reuseIdentifier of their associated VAbstractMarqueeStreamItemmCell subclass
 
    @return An NSString representing the reuse identifier of cells that will be registered with the collection view managed by this marquee controller.
 */
- (NSString *)cellSuggestedReuseIdentifier;

/**
    Overridden by subclasses to surface the desired size for the collection view that this marquee controller manages. In most instances, subclasses should just return the desired size of their associated VAbstractMarqueeCollectionViewCell subclass
 
    @return A CGSize corresponding to the desired size of the collection view that this marquee controller manages
 */
- (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds;

@end
