//
//  VFullscreenMarqueeStreamItemCell.h
//  victorious
//
//  Created by Will Long on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractMarqueeStreamItemCell.h"
#import "VBackgroundContainer.h"

@class VFullscreenMarqueeStreamItemCell, VUser;

extern CGFloat const kVDetailVisibilityDuration;
extern CGFloat const kVDetailHideDuration;

/**
 *  A cell that displays a streamItem for a Marquee
 */
@interface VFullscreenMarqueeStreamItemCell : VAbstractMarqueeStreamItemCell <VBackgroundContainer>

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

@end
