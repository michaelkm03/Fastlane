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
#import "VLoginViewController.h"

@implementation VAppDelegate

+ (VAppDelegate*) sharedAppDelegate
{
    return (VAppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupRestKit];
    
    //[VLoginManager createVictoriousAccountWithEmail:@"a" password:@"a" name:@"a"];
    //[VLoginManager loginToVictoriousWithEmail:@"a" andPassword:@"a"];
    [VLoginManager loginToFacebook];
//    [self performSelector:@selector(login) withObject:nil afterDelay:1.0];
    
    return YES;
}

- (void)login
{
    [self.window.rootViewController presentViewController:[VLoginViewController sharedLoginViewController] animated:YES completion:NULL];
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
- (void)setupRestKit
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
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"victoriOS" withExtension:@"momd"];

    NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];

    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    manager.managedObjectStore = managedObjectStore;

    // Initialize the Core Data stack
    NSError *error;
    [managedObjectStore createPersistentStoreCoordinator];
    
    NSPersistentStore __unused *persistentStore = [managedObjectStore addInMemoryPersistentStore:&error];
    NSAssert(persistentStore, @"Failed to add persistent store: %@", error);

    [managedObjectStore createManagedObjectContexts];
    
    // Configure a managed object cache to ensure we do not create duplicate objects
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];

    [self declareDescriptors];
    
    //This will allow us to call this manager with [RKObjectManager sharedManager]
    [RKObjectManager setSharedManager:manager];
}

- (void)declareDescriptors
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
                                                                       [Sequence sequenceListDescriptor],
                                                                       [Sequence sequenceFullDataDescriptor],
                                                                       [Comment descriptor],
                                                                       [Comment getAllDescriptor],
                                                                       [StatSequence gamesPlayedDescriptor],
                                                                       [StatSequence gameStatsDescriptor]]];
}

@end
