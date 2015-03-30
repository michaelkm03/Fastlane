//
//  VMarqueeStreamItemCell.h
//  victorious
//
//  Created by Will Long on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBaseCollectionViewCell.h"

extern CGFloat const kVDetailVisibilityDuration;
extern CGFloat const kVDetailHideDuration;

@class VStreamItem, VUser, VMarqueeStreamItemCell, VDefaultProfileButton, VDependencyManager;

/**
 *  Delegate for a VMarqueeStreamItemCell
 */
@protocol VMarqueeCellDelegate <NSObject>

- (void)cell:(VMarqueeStreamItemCell *)cell selectedUser:(VUser *)user;///<Sent when the user button is clicked in a marquee cell

@end

/**
 *  A cell that displays a streamItem for a Marquee
 */
@interface VMarqueeStreamItemCell : VBaseCollectionViewCell

/**
 Adjust the visibility of the "detail" view on the bottom of the marquee cell.
 This function does NOT automatically start the timer to hide the details view.
 
 @param visible Determines whether or not the details container is visible
 @param animated Determines whether or not the change in visibility is animated or not
 */
- (void)setDetailsContainerVisible:(BOOL)visible animated:(BOOL)animated;

/**
 Start the timer to hide the detail view
 */
- (void)restartHideTimer;

@property (nonatomic, strong) VStreamItem *streamItem; ///<Stream item to display
@property (nonatomic, weak) id<VMarqueeCellDelegate> delegate;
@property (nonatomic, weak, readonly) UIImageView *previewImageView;
@property (nonatomic, assign) BOOL hideMarqueePosterImage;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
