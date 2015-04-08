//
//  VMarqueeStreamItemCell.h
//  victorious
//
//  Created by Will Long on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractMarqueeStreamItemCell.h"

@class VFullscreenMarqueeStreamItemCell, VUser;

extern CGFloat const kVDetailVisibilityDuration;
extern CGFloat const kVDetailHideDuration;

/**
 *  Delegate for a VMarqueeStreamItemCell
 */
@protocol VFullscreenMarqueeCellDelegate <NSObject>

- (void)cell:(VFullscreenMarqueeStreamItemCell *)cell selectedUser:(VUser *)user;///<Sent when the user button is clicked in a marquee cell

@end

/**
 *  A cell that displays a streamItem for a Marquee
 */
@interface VFullscreenMarqueeStreamItemCell : VAbstractMarqueeStreamItemCell

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

@property (nonatomic, weak) id <VFullscreenMarqueeCellDelegate> delegate; ///< The delegate that will recieve messages when a user is selected from marquee content
@property (nonatomic, assign) BOOL hideMarqueePosterImage; ///< Toggles display of poster's profile image in the center of the marquee content

@end
