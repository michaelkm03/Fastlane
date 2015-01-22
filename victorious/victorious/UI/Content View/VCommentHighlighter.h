//
//  VCommentHighlighter.h
//  victorious
//
//  Created by Patrick Lynch on 1/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A helper class that primary animates the contentOffset (scroll position) of a collection view
 and highlights a specific cell to call the attention of the user.
 */
@interface VCommentHighlighter : NSObject

/**
 Returns YES if the animations triggered by `scrollToAndHighlightIndexPath:delay:completion` are
 still active.  Typically, calling code will want to prevent reloading collection views
 while this animation is active to prevent changing the contentOffset or dequeuing cells that might
 be animating.
 */
@property (nonatomic, assign, readonly) BOOL isAnimatingCellHighlight;

/**
 The desginated initializer requiring a collectionView to work with so it can control
 animation of the contentOffset and cells within.
 */
- (instancetype)initWithCollectionView:(UICollectionView *)collectionView NS_DESIGNATED_INITIALIZER;

/**
 Trigger an animation that scrolls to and highlights the cell at the specified index
 path to call the attention of the user to that cell.
 */
- (void)scrollToAndHighlightIndexPath:(NSIndexPath *)indexPath delay:(NSTimeInterval)delay completion:(void(^)())completion;

/**
 Stops any active processes related to animation, including invalidating timers.  Typically
 calling code will want to call this in `viewDidDisappear` or similar methods to prevent
 animation from continuing while the a view controller or view is not visible or in focus.
 The `completion` callback supplied to `scrollToAndHighlightIndexPath:delay:completion` will
 not be called if this method is called before the end of any currently active animations.
 */
- (void)stopAnimations;

@end
