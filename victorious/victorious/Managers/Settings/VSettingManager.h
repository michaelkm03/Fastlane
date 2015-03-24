//
//  VExperimentManager.h
//  victorious
//
//  Created by Will Long on 6/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVoteSettings.h"

@class VDependencyManager;

//Experiments
extern NSString * const VExperimentsRequireProfileImage;
extern NSString * const VExperimentsPauseVideoWhenCommenting;
extern NSString * const VExperimentsClearVideoBackground;

@class VTracking;

@interface VSettingManager : NSObject

@property (nonatomic, strong) VDependencyManager *dependencyManager;

+ (instancetype)sharedManager;

- (BOOL)settingEnabledForKey:(NSString *)settingKey;

- (NSURL *)urlForKey:(NSString *)key;

@end
