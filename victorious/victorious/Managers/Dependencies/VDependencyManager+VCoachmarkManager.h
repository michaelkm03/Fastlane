//
//  VDependencyManager+VCoachmarkManager.h
//  victorious
//
//  Created by Sharif Ahmed on 5/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"

/**
    A convenient category for getting the coachmark manager managed by the scaffold
 */
@class VCoachmarkManager;

@interface VDependencyManager (VCoachmarkManager)

/**
    Returns the coachmark manager of the scaffold, simply a convenience
 */
- (VCoachmarkManager *)coachmarkManager;

@end
