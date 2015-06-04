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

extern NSString * const kMarqueeURLKey;

@class VDependencyManager, VStream, VStreamItem, VTimerManager, VUser, VAbstractMarqueeCollectionViewCell, VAbstractMarqueeStreamItemCell;

/**
    A controller responsible for managing the content offset of the collection view, updating the collection view when marquee content changes,
        populating the stream item cells in the collection view, and relaying messages to delegates when marquee content changes or the user
        interacts with the marquee
 */
@interface VAbstractMarqueeController : NSObject <UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) id <VMarqueeSelectionDelegate> selectionDelegate; ///< The object that should be notified of selections of marquee content
@property (nonatomic, weak) id <VMarqueeDataDelegate> dataDelegate; ///< The object that should be notified of changes in marquee content

@property (nonatomic, strong) UICollectionView *collectionView; ///< The colletion view used to display the streamItems
@property (nonatomic, readonly) VStreamItem *currentStreamItem; ///< The stream item currently being displayed
@property (nonatomic, strong) VStream *stream; ///< The Marquee Stream
@property (nonatomic, readonly) VTimerManager *autoScrollTimerManager; ///< The timer in control of auto scroll

/**
    The dependencyManager used to style the streamItem cells that are managed by this marquee controller.
        This is automatically set by the marquee collection view cell associated with this marquee controller
 */
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, readonly) NSUInteger currentPage; ///< The current page of marquee content being displayed

/**
    Initializes the marquee cell factory with an instance of VDependencyManager
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager NS_DESIGNATED_INITIALIZER;

/**
    Sends -registerClass:forCellWithReuseIdentifier: and -registerNib:forCellWithReuseIdentifier:
        messages to the collection view. Should be called as soon as the collection view is initialized.
 */
- (void)registerStreamItemCellsWithCollectionView:(UICollectionView *)collectionView forMarqueeItems:(NSArray *)marqueeItems;

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

#pragma mark - Abstract methods

/**
    Overridden by subclasses to provide a fully configured marquee cell for use in the provided collectionView.
    This should use the same reuse identifier
 */
- (VAbstractMarqueeCollectionViewCell *)marqueeCellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath;

/**
    Overridden by subclasses to surface the desired size for the collection view that this marquee controller manages.
        In most instances, subclasses should just return the desired size of their
        associated VAbstractMarqueeCollectionViewCell subclass
 
    @return A CGSize corresponding to the desired size of the collection view that this marquee controller manages
 */
- (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds;

/**
    Overridden by subclasses to register the proper VAbstractMarqueeCollectionViewCell subclass with the provided collectionView.
 */
- (void)registerCollectionViewCellWithCollectionView:(UICollectionView *)collectionView;

/**
    Overridden by subclasses to provide the dependency manager and stream item to the provided cell as necessary.
    Most cases will simply use the following implementation:

    - (void)setupStreamItemCell:(VAbstractMarqueeStreamItemCell *)streamItemCell withDependencyManager:(VDependencyManager *)dependencyManager andStreamItem:(VStreamItem *)streamItem
    {
        streamItemCell.dependencyManager = dependencyManager;
        streamItemCell.streamItem = streamItem;
    }
 
    @param streamItemCell The stream item cell that should be populated with the provided dependency manager and stream item.
    @param dependencyManager The dependency manager that should be used to style the cell.
    @param streamItem The stream item whose content should populate the streamItemCell.
 */
- (void)setupStreamItemCell:(VAbstractMarqueeStreamItemCell *)streamItemCell withDependencyManager:(VDependencyManager *)dependencyManager andStreamItem:(VStreamItem *)streamItem;

/**
    Overridden by subclasses to provide an appropriate subclass of VAbstractMarqueeStreamItemCell whose reuse will be managed by this class.
 */
+ (Class)marqueeStreamItemCellClass;

@end
