//
//  VMarqueeController.h
//  victorious
//
//  Created by Will Long on 9/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractMarqueeController.h"
#import "VFullscreenMarqueeControllerDelegate.h"

@class VFullscreenMarqueeTabIndicatorView;

@interface VFullscreenMarqueeController : VAbstractMarqueeController

@property (nonatomic, weak) VFullscreenMarqueeTabIndicatorView *tabView; ///< The Marquee tab view to update
@property (nonatomic, assign) BOOL hideMarqueePosterImage; ///< Toggles display of poster's profile image in the center of the marquee content
@property (nonatomic, weak) id <VFullscreenMarqueeControllerDelegate> delegate; ///< The delegate that will recieve messages about selected marquee or selected user content

@end
