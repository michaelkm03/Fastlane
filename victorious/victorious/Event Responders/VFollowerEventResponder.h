//
//  VFollowerCommandHandler.h
//  victorious
//
//  Created by Michael Sena on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VResponder.h"
#import "VFollowEvent.h"

@class VDependencyManager;

/**
 *  VFollowerCommandHandler executes requests from the responder chain to follow a particular user.
 */
@interface VFollowerEventResponder : VResponder <VFollowEvent>

/**
 *  Will present authorization on this viewController must not be nil 
 *  by the time VFollowerCommandHandler receives VFollowCommands.
 *
 *  Temporary until authorization is incorporated to the command system.
 */
@property (nonatomic, weak) UIViewController *viewControllerToPresentAuthorizationOn;

/**
 *  Required for authorization. 
 *
 *  Temporary until authorization is incorporated to the command system.
 */
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
