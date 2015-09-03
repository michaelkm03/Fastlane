//
//  VStreamFocusHelper.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A helper class that handles setting focus on cells when
 a tableView or a collectionView is scrolled. Cells must
 conform to VCellFocus protocol in order to focus
 properly.
 */
@interface VStreamFocusHelper : NSObject

/**
 A value between 0 and 1 that determines the amount of 
 the cell's content area that needs to be on the screen in 
 order for focus to be registered. For example, if this is 
 set to 0.8, then 80% of the cell's content view needs to be
 on screen before the cell is considered to be in focus. 
 Defaults to 0.8.
 */
@property (nonatomic, assign) CGFloat visibilityRatio;


/**
 Specify the amount in which to inset the focus area
 */
@property (nonatomic, assign) UIEdgeInsets focusAreaInsets;

@property (nonatomic, weak) UICollectionViewCell *selectedCell;

/**
 Updates focus on all visible cells.
 */
- (void)updateFocus;

/**
 Ends focus on particular cells.
 */
- (void)endFocusOnCell:(UIView *)cell;

/**
 Ends focus on all visible cells.
 */
- (void)endFocusOnAllCells;

/**
 Subclasses MUST override this method and return
 a valid scrollView in order to update cell focus.
 */
- (UIScrollView *)scrollView;

/**
 Subclasses MUST override this method and return
 an array of cells to update focus on.
 */
- (NSArray *)visibleCells;

@end
