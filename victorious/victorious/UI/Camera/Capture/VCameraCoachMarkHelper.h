//
//  VCameraCoachMarkHelper.h
//  victorious
//
//  Created by Michael Sena on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCameraCoachMarkHelper : NSObject

/**
 *  Initializes a VCameraCoachMarkHelper with the given coach view. The coachView's 
 *  alpha property will now be managed by the coach mark helper.
 */
- (instancetype)initWithCoachView:(UIView *)coachView;

/**
 *  Animates to full opacity. Should only be called on initial appearance.
 */
- (void)fadeIn;

/**
 *  Animate to zero opacity. Switches internal state to allow calls to "-flash" to
 *  animate the opacity to zero.
 */
- (void)fadeOut;

/**
 *  Does nothing if hasn't yet received a fadeOut message.
 */
- (void)flash;

@end
