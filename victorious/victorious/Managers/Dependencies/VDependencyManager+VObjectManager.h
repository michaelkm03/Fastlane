//
//  VDependencyManager+VObjectManager.h
//  victorious
//
//  Created by Josh Hinman on 11/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"

extern NSString * const VDependencyManagerObjectManagerKey; ///< An instance of VObjectManager

@class VObjectManager;

@interface VDependencyManager (VObjectManager)

/**
 An instance of VObjectManager
 */
- (VObjectManager *)objectManager;

@end
