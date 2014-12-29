//
//  VPublishBlurOverAnimator.h
//  victorious
//
//  Created by Michael Sena on 12/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  An animator object for blurring over the workspace while pushing.
 */
@interface VPublishBlurOverAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting; ///< If we are presenting or not.

@end
