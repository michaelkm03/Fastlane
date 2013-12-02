//
//  VAppDelegate.m
//  victoriOS
//
//  Created by Will Long on 11/25/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VAppDelegate.h"
#import "VLoginManager.h"
#import "VObjectManager.h"
#import "User+RestKit.h"
#import "VCategory+RestKit.h"
#import "Sequence+RestKit.h"
#import "StatSequence+RestKit.h"

@implementation VAppDelegate

//@synthesize managedObjectContext = _managedObjectContext;
/*TODO: remove once RestKit is working
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
*/

+ (VAppDelegate*) sharedAppDelegate
{
    return (VAppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self setupRestKit];
    
    [VLoginManager loginToFacebook];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}

#pragma mark - RestKit Methods
-(void)setupRestKit
{
    
#if DEBUG
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
#endif
    
    RKObjectManager *manager = [VObjectManager managerWithBaseURL:[NSURL URLWithString:VBASEURL]];
    
    //Add the App ID to the User-Agent field
    //(this is the only non-dynamic header, so set it now)
    NSString* userAgent = [[manager HTTPClient].defaultHeaders objectForKey:@"User-Agent"];

    //TODO: use real app id once we set that up
    userAgent = [NSString stringWithFormat:@"%@ aid:%@", userAgent, @"1"];
    [[manager HTTPClient] setDefaultHeader:@"User-Agent" value:userAgent];

    //TODO: we need to grab the momd manually by URL
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    manager.managedObjectStore = managedObjectStore;
    
    [managedObjectStore createPersistentStoreCoordinator];
    
    //TODO: don't create
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"Victorious.sqlite"];
    
    NSError *error;
    
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error];
    
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    
    [managedObjectStore createManagedObjectContexts];
    
    // Configure a managed object cache to ensure we do not create duplicate objects
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];

    [self declareDescriptors];
    
    //This will allow us to call this manager with [RKObjectManager sharedManager]
    [RKObjectManager setSharedManager:manager];
}

-(void)declareDescriptors
{

    //Should one of our requests to get data fail, RestKit will use this mapping and send us an NSError object with the error message of the response as the string.
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:
     [RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorDescriptor = [RKResponseDescriptor
                                             responseDescriptorWithMapping:errorMapping
                                             method:RKRequestMethodAny
                                             pathPattern:nil
                                             keyPath:@"message"
                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    [[RKObjectManager sharedManager] addResponseDescriptorsFromArray:@[errorDescriptor,
                                                                       [User descriptor],
                                                                       [VCategory descriptor],
                                                                       [Sequence sequenceListDescriptor]]];
                                                                       //[StatSequence descriptor]]];
}

@end
