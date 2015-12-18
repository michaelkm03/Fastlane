//
//  VEnvironmentManager.m
//  victorious
//
//  Created by Josh Hinman on 5/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSArray+VMap.h"
#import "VEnvironment.h"
#import "VEnvironmentManager.h"
#import "VConstants.h"

static NSString * const kCurrentEnvironmentKey = @"com.victorious.VEnvironmentManager.Environment.currentEnvironment";
static NSString * const kPreviousEnvironmentKey = @"com.victorious.VEnvironmentManager.Environment.previousEnvironment";
static NSString * const kEnvironmentsFilename = @"environments";
static NSString * const kUserEnvironmentsFilename = @"user_environments.plist";
static NSString * const kPlist = @"plist";

@interface VEnvironmentManager()

@property (nonatomic, readonly) NSArray *bundleEnvironments;
@property (nonatomic, strong) NSArray *userEnvironments;

@end

@implementation VEnvironmentManager

+ (instancetype)sharedInstance
{
    static VEnvironmentManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if ( self != nil )
    {
        NSString *defaultEnvironment = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"VictoriousServerEnvironment"];
        if (defaultEnvironment)
        {
            [[NSUserDefaults standardUserDefaults] registerDefaults:@{ kCurrentEnvironmentKey: defaultEnvironment }];
        }
        
        NSString *filepath = [self userEnvironmentsFilePathWithFilename:kUserEnvironmentsFilename];
        NSArray *environments = [NSKeyedUnarchiver unarchiveObjectWithFile:filepath];
        _userEnvironments = environments ?: @[];
    }
    return self;
}

- (VEnvironment *)currentEnvironment
{
    NSString *environmentName = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentEnvironmentKey];
    return [self environmentWithName:environmentName];
}

- (VEnvironment *)environmentWithName:(NSString *)name
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name==%@", name];
    VEnvironment *environment = [[self.allEnvironments filteredArrayUsingPredicate:predicate] lastObject];
    return environment;
}

- (void)setCurrentEnvironment:(VEnvironment *)currentEnvironment
{
    if ([self.allEnvironments containsObject:currentEnvironment])
    {
        // Save the previous environment
        NSString *currentEnvironmentName = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentEnvironmentKey];
        if ( currentEnvironmentName != nil )
        {
            [[NSUserDefaults standardUserDefaults] setObject:currentEnvironmentName forKey:kPreviousEnvironmentKey];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:currentEnvironment.name forKey:kCurrentEnvironmentKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)revertToPreviousEnvironment
{
    NSString *previousEnvironmentName = [[NSUserDefaults standardUserDefaults] stringForKey:kPreviousEnvironmentKey];
    if ( previousEnvironmentName != nil )
    {
        [self setCurrentEnvironment:[self environmentWithName:previousEnvironmentName]];
        [[NSUserDefaults standardUserDefaults] setObject:previousEnvironmentName forKey:kCurrentEnvironmentKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (BOOL)addEnvironment:(VEnvironment *)environment
{
    if ( environment == nil )
    {
        return NO;
    }
    if ( environment.name == nil || environment.name.length == 0 )
    {
        return NO;
    }
    if ( environment.baseURL == nil || environment.baseURL.absoluteString.length == 0 )
    {
        return NO;
    }
    if ( environment.appID == nil || environment.appID.integerValue == 0 )
    {
        return NO;
    }
    
    environment.isUserEnvironment = YES; // All added environments are considered user environments
    
    self.userEnvironments = [self.userEnvironments arrayByAddingObject:environment];
    NSString *filepath = [self userEnvironmentsFilePathWithFilename:kUserEnvironmentsFilename];
    BOOL success = [NSKeyedArchiver archiveRootObject:self.userEnvironments toFile:filepath];
    return success;
}

- (NSString *)userEnvironmentsFilePathWithFilename:(NSString *)path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    return [[paths firstObject] stringByAppendingPathComponent:path];
}

- (NSArray *)allEnvironments
{
    return [self.bundleEnvironments arrayByAddingObjectsFromArray:self.userEnvironments];
}

- (NSArray *)bundleEnvironments
{
    static NSArray *bundleEnvironments;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
    {
        NSURL *environmentsConfigurationURL = [[NSBundle bundleForClass:[self class]] URLForResource:kEnvironmentsFilename withExtension:kPlist];
        bundleEnvironments = [VEnvironment environmentsFromPlist:environmentsConfigurationURL];
    });
    return bundleEnvironments;
}

@end
