//
//  VFromTopViewControllerAnimator.h
//  victorious
//
//  Created by Michael Sena on 7/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Presentation animator that animates from the top. When dismissing will animate away to the top.
 */
@interface VFromTopViewControllerAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting;

@end
