//
//  VFlowController.h
//  victorious
//
//  Created by Michael Sena on 1/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^VFlowControllerCompletion)(BOOL finished);

@protocol VFlowController <NSObject>

@required

@property (nonatomic, readonly) UIViewController *rootViewControllerOfFlow;

@property (nonatomic, copy) VFlowControllerCompletion completion;

@end
