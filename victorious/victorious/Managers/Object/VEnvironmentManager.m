//
//  VEnvironmentManager+Environment.m
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
static NSString * const kEnvironmentsFilename = @"environments";
static NSString * const kUserEnvironmentsFilename = @"user_environments";
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

- (VEnvironment *)currentEnvironment
{
    NSString *defaultEnvironment = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"VictoriousServerEnvironment"];
    if (defaultEnvironment)
    {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{ kCurrentEnvironmentKey: defaultEnvironment }];
    }
    
    NSString *environmentName = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentEnvironmentKey];
    return [[self.allEnvironments filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name==%@", environmentName]] lastObject];
}

- (void)setCurrentEnvironment:(VEnvironment *)currentEnvironment
{
    if ([self.allEnvironments containsObject:currentEnvironment])
    {
        [[NSUserDefaults standardUserDefaults] setObject:currentEnvironment.name forKey:kCurrentEnvironmentKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)addEnvironment:(VEnvironment *)currentEnvironment
{
    self.userEnvironments = [(self.userEnvironments ?: @[]) arrayByAddingObject:currentEnvironment];
    NSString *filepath = [self userEnvironmentsFilePathWithFilename:kUserEnvironmentsFilename];
    if ( [self.userEnvironments writeToFile:filepath atomically:YES] )
    {
        NSLog( @"Error adding user environment." );
    }
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
        bundleEnvironments = [NSArray arrayWithArray:environments];
    });
    return bundleEnvironments;
}

- (NSURL *)documentsDirectoryWithPath:(NSString *)path
{
    NSString *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    return [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:path]];
}

@end
