//
//  VHasManagedDependencies.h
//  victorious
//
//  Created by Josh Hinman on 11/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#include <Foundation/Foundation.h>

@class VDependencyManager;

/**
 Objects conforming to this protocol have dependencies
 that are managed by an instance of VDependencyManager
 */
@protocol VHasManagedDependencies <NSObject>

@optional // One or more of the following three methods should be implemented.

/**
 Initializes the receiver with an instance of VDependencyManager
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 Creates a new instance of the receiver by passing in an instance of VDependencyManager
 */
+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 Provides the receiver with an instance of VDependencyManager
 */
- (void)setDependencyManager:(VDependencyManager *)dependencyManager;

@optional

- (VDependencyManager *)dependencyManager;

@end
