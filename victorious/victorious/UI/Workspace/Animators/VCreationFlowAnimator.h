//
//  VCreationFlowAnimator.h
//  victorious
//
//  Created by Michael Sena on 7/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCreationFlowAnimator : NSObject <UIViewControllerAnimatedTransitioning>

/**
 *  Set to yes for the presenting version of the animation, NO for the dismissal.
 */
@property (nonatomic, assign) BOOL presenting;

@end
