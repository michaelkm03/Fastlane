//
//  VObjectManager+Environment.m
//  victorious
//
//  Created by Josh Hinman on 5/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VEnvironment.h"
#import "VObjectManager+Environment.h"
#import "VConstants.h"

static NSString * const kCurrentEnvironmentKey = @"com.victorious.VObjectManager.Environment.currentEnvironment";

@implementation VObjectManager (Environment)

+ (VEnvironment *)currentEnvironment
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
    {
        NSString *defaultEnvironment = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"VictoriousServerEnvironment"];
        if (defaultEnvironment)
        {
            [[NSUserDefaults standardUserDefaults] registerDefaults:@{ kCurrentEnvironmentKey: defaultEnvironment }];
        }
    });
    
    NSString *environmentName = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentEnvironmentKey];
    return [[self.allEnvironments filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name==%@", environmentName]] lastObject];
}

+ (void)setCurrentEnvironment:(VEnvironment *)currentEnvironment
{
    if ([self.allEnvironments containsObject:currentEnvironment])
    {
        [[NSUserDefaults standardUserDefaults] setObject:currentEnvironment.name forKey:kCurrentEnvironmentKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSArray *)allEnvironments
{
    static NSArray *allEnvironments;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
    {
        allEnvironments =
        @[
#ifndef V_NO_SWITCH_ENVIRONMENTS
          
          [[VEnvironment alloc] initWithName:@"Local" baseURL:[NSURL URLWithString:@"http://local.getvictorious.com"]
                                       appID:@(kDevAppID)],
            [[VEnvironment alloc] initWithName:@"Dev" baseURL:[NSURL URLWithString:@"http://dev.getvictorious.com"]
                                         appID:@(kDevAppID)],
            [[VEnvironment alloc] initWithName:@"QA" baseURL:[NSURL URLWithString:@"http://qa.getvictorious.com"]
                                         appID:[[NSBundle mainBundle] objectForInfoDictionaryKey:kQAAppIDKey]],
            [[VEnvironment alloc] initWithName:@"Staging" baseURL:[NSURL URLWithString:@"https://staging.getvictorious.com"]
                                         appID:[[NSBundle mainBundle] objectForInfoDictionaryKey:kStagingAppIDKey]],
#endif
            [[VEnvironment alloc] initWithName:@"Production" baseURL:[NSURL URLWithString:@"https://api.getvictorious.com"]
                                         appID:[[NSBundle mainBundle] objectForInfoDictionaryKey:kVictoriousAppIDKey]]
        ];
    });
    return allEnvironments;
}

@end
