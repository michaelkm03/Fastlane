//
//  VObjectManager+Environment.h
//  victorious
//
//  Created by Josh Hinman on 5/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"

@class VEnvironment;

/**
 This category contains methods related to getting/setting the current server environment.
 */
@interface VObjectManager (Environment)

+ (VEnvironment *)currentEnvironment;
+ (void)setCurrentEnvironment:(VEnvironment *)newEnvironment;
+ (NSArray *)allEnvironments; ///< array of VEnvironment objects
+ (NSURL*)addExtensionToBaseURL:(NSString*)extensions;

@end
