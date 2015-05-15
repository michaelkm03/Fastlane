//
//  VObjectManager+Environment.m
//  victorious
//
//  Created by Josh Hinman on 5/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSArray+VMap.h"
#import "VEnvironment.h"
#import "VObjectManager+Environment.h"
#import "VConstants.h"

static NSString * const kCurrentEnvironmentKey = @"com.victorious.VObjectManager.Environment.currentEnvironment";
static NSString * const kEnvironmentsFilename = @"environments";
static NSString * const kPlist = @"plist";

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
        NSURL *environmentsConfigurationURL = [[NSBundle bundleForClass:self] URLForResource:kEnvironmentsFilename withExtension:kPlist];
        NSInputStream *fileStream = [[NSInputStream alloc] initWithURL:environmentsConfigurationURL];
        [fileStream open];
        NSArray *environmentsPlist = [NSPropertyListSerialization propertyListWithStream:fileStream options:0 format:nil error:nil];
        [fileStream close];
        
        NSMutableArray *environments = [[NSMutableArray alloc] initWithCapacity:environmentsPlist.count];
        for ( NSDictionary *environmentDictionary in environmentsPlist)
        {
            if ( [environmentDictionary isKindOfClass:[NSDictionary class]] )
            {
                VEnvironment *environment = [[VEnvironment alloc] initWithDictionary:environmentDictionary];
                if ( environment != nil )
                {
                    [environments addObject:environment];
                }
            }
        }
        allEnvironments = [NSArray arrayWithArray:environments];
    });
    return allEnvironments;
}

@end
