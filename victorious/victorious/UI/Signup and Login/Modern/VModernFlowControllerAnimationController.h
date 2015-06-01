//
//  VModernFlowControllerAnimationController.h
//  victorious
//
//  Created by Michael Sena on 5/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  The modern flow controller animation controller provides push/pop animations for the modern flow controller.
 */
@interface VModernFlowControllerAnimationController : NSObject <UIViewControllerAnimatedTransitioning>

/**
 *  Whether or not the navigation stack is popping. Should be set before this is returned in the 
 *  navigation controller's delegate method.
 */
@property (nonatomic, assign) BOOL popping;

@end
