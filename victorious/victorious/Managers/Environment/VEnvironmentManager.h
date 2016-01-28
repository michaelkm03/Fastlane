//
//  VEnvironmentManager.h
//  victorious
//
//  Created by Josh Hinman on 5/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VEnvironment;

NS_ASSUME_NONNULL_BEGIN

/**
 This category contains methods related to getting/setting the current server environment.
 */
@interface VEnvironmentManager : NSObject

@property (nonatomic, strong) VEnvironment *currentEnvironment;
@property (nonatomic, readonly) NSArray *allEnvironments; ///< array of VEnvironment objects

+ (instancetype)sharedInstance;

- (BOOL)addEnvironment:(VEnvironment *)environment;
- (void)revertToPreviousEnvironment;

@end

NS_ASSUME_NONNULL_END
