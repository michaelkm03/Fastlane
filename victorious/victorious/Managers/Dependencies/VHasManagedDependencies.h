//
//  VHasManagedDependencies.h
//  victorious
//
//  Created by Josh Hinman on 11/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VDependencyManager;

/**
 Objects conforming to this protocol have dependencies
 that are managed by an instance of VDependencyManager
 */
@protocol VHasManagedDependancies <NSObject>

@optional // One of the following two methods should be implemented

@property (nonatomic, readonly) VDependencyManager *dependencyManager;

/**
 Initializes the receiver with an instance of VDependencyManager
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 Creates a new instance of the receiver by passing in an instance of VDependencyManager
 */
+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
