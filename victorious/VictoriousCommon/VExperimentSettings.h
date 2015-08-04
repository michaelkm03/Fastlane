//
//  VExperimentSettings.h
//  victorious
//
//  Created by Patrick Lynch on 8/3/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Stores a list of active experiment IDs kept synched internally by NSUserDefaults.
 Multiple instances of this class can be used independenctly and NSUserDefaults
 will keep values synched.
 */
@interface VExperimentSettings : NSObject

/**
 A set of the user-selected experiments to be active in all subsequent backend interactions
 */
@property (nonatomic, strong, nullable) NSSet *activeExperiments;

/**
 Returns a command-separated list of hte active experiments for use in request header.
 */
@property (nonatomic, readonly, copy) NSString *commaSeparatedList;

/**
 Removes all active experiments and clears value in NSUserDefaults.
 This will return the application to membership in experiments as determined by the backend,
 essentially undoing and previously user-selected experiment memberships.
 */
- (void)reset;

@end

NS_ASSUME_NONNULL_END