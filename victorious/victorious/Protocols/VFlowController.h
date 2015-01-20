//
//  VFlowController.h
//  victorious
//
//  Created by Michael Sena on 1/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A completion block for flow controllers.
 */
typedef void (^VFlowControllerCompletion)(BOOL finished);

/**
 *  A protocol for flow controllers to implement.
 */
@protocol VFlowController <NSObject>

@required

/**
 *  The Root viewController of the flow controller present this.
 */
@property (nonatomic, readonly) UIViewController *flowRootViewController;

/**
 *  The completion block that will be called by the flow controller.
 */
@property (nonatomic, copy) VFlowControllerCompletion completion;

@end
