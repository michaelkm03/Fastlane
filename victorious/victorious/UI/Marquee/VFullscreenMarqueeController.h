//
//  VFullscreenMarqueeController.h
//  victorious
//
//  Created by Will Long on 9/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractMarqueeController.h"
#import "VFullscreenMarqueeSelectionDelegate.h"

@class VFullscreenMarqueeTabIndicatorView;

@interface VFullscreenMarqueeController : VAbstractMarqueeController

@property (nonatomic, weak) VFullscreenMarqueeTabIndicatorView *tabView; ///< The Marquee tab view to update
@property (nonatomic, assign) BOOL hideMarqueePosterImage; ///< Toggles display of poster's profile image in the center of the marquee content

@end
