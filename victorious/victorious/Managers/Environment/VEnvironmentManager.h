//
//  VEnvironmentManager.h
//  victorious
//
//  Created by Josh Hinman on 5/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VEnvironmentManager.h"
#import "VEnvironment.h"

/**
 This category contains methods related to getting/setting the current server environment.
 */
@interface VEnvironmentManager : NSObject

@property (nonatomic, strong) VEnvironment *currentEnvironment;

@property (nonatomic, readonly) NSArray *allEnvironments; ///< array of VEnvironment objects

+ (instancetype)sharedInstance;

- (BOOL)addEnvironment:(VEnvironment *)currentEnvironment;

- (void)revertToPreviousEnvironment;

@end
