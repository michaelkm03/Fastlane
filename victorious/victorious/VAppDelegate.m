//
//  VAppDelegate.m
//  victoriOS
//
//  Created by Will Long on 11/25/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VAppDelegate.h"
#import <TestFlightSDK/TestFlight.h>
#import "VThemeManager.h"
#import "VReachability.h"

#import "VAnalyticsRecorder.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Login.h"
#import "VUserManager.h"

#import "VConstants.h"

@import MediaPlayer;
@import CoreLocation;

@interface VAppDelegate ()  <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager*            locationManager;
@property (nonatomic, strong) CLGeocoder*                   geoCoder;
@end

@implementation VAppDelegate

+ (VAppDelegate*) sharedAppDelegate
{
    return (VAppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    srand48(time(0));

//    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    [[VThemeManager sharedThemeManager] applyStyling];

//    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
//    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
//    if (localNotif)
//    {
//        NSString *itemName = [localNotif.userInfo objectForKey:ToDoItemKey];
//        [viewController displayItem:itemName];  // custom method
//        app.applicationIconBadgeNumber = localNotif.applicationIconBadgeNumber-1;
//    }
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[VReachability reachabilityForInternetConnection] startNotifier];

    [VObjectManager setupObjectManager];

    [self initLocationForAPIHeader];
    [self determineLocationForAPIHeader];

#ifdef QA
    [TestFlight takeOff:[[NSBundle mainBundle] objectForInfoDictionaryKey:kTestflightQAToken]];
#elif STAGING
    [TestFlight takeOff:[[NSBundle mainBundle] objectForInfoDictionaryKey:kTestflightStagingToken]];
#elif DEBUG
#else
    [TestFlight takeOff:[[NSBundle mainBundle] objectForInfoDictionaryKey:kTestflightReleaseToken]];
#endif
    
    // Initialize the chromecast device controller.
    self.chromecastDeviceController = [[ChromecastDeviceController alloc] init];
    
    // Scan for devices.
    [self.chromecastDeviceController performScan:YES];

    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAnalytics];
    
    NSURL*  openURL =   launchOptions[UIApplicationLaunchOptionsURLKey];
    if (openURL)
        [self handleOpenURL:openURL];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [self handleOpenURL:url];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[VThemeManager sharedThemeManager] updateToNewTheme];
    [[VObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext saveToPersistentStore:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self determineLocationForAPIHeader];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[VThemeManager sharedThemeManager] updateToNewTheme];
    [[VObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext saveToPersistentStore:nil];
}

//- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//{
//    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
//    
//    NSURL *url = [[NSURL alloc] initWithString:@"http://yourserver.com/data.json"];
//    NSURLSessionDataTask *task = [session dataTaskWithURL:url
//                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
//    {
//        if (error)
//        {
//            completionHandler(UIBackgroundFetchResultFailed);
//            return;
//        }
//                                            
//        // Parse response/data and determine whether new content was available
//        BOOL hasNewData = NO;
//        if (hasNewData)
//        {
//            completionHandler(UIBackgroundFetchResultNewData);
//        }
//        else
//        {
//            completionHandler(UIBackgroundFetchResultNoData);
//        }
//    }];
//    
//    // Start the task
//    [task resume];
//}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//{
//    NSLog(@"Remote Notification userInfo is %@", userInfo);
//    
////    NSNumber *contentID = userInfo[@"content-id"];
//    // Do something with the content ID
//    completionHandler(UIBackgroundFetchResultNewData);
//}

//- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
//{
////    const void *devTokenBytes = [devToken bytes];
////    self.registered = YES;
////    [self sendProviderDeviceToken:devTokenBytes]; // custom method
//}

//- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
//{
//    NSLog(@"Error in registration. Error: %@", err);
//}

#pragma mark - Deep Linking

- (void)handleOpenURL:(NSURL *)aURL
{
    NSString*   linkString = [aURL resourceSpecifier];
    NSError*    error = NULL;

    for (NSString* pattern in [[self deepLinkPatterns] allKeys])
    {
        NSRegularExpression*    regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                  options:NSRegularExpressionCaseInsensitive
                                                                                    error:&error];
        
        NSTextCheckingResult *result = [regex firstMatchInString:linkString
                                                         options:NSMatchingAnchored
                                                           range:NSMakeRange(0, linkString.length)];
        
        if (result)
        {
            NSMutableArray* captures = [NSMutableArray array];
            for (int i=1; i < result.numberOfRanges; i++)
            {
                NSRange range = [result rangeAtIndex:i];
                NSString*   capture = [linkString substringWithRange:range];
                [captures addObject:capture];
            }
            
            //  This may look ugly, but this provides greater type safety than simply calling performSelector, allowing ARC to perform correctly.
            SEL selector = NSSelectorFromString([[self deepLinkPatterns] objectForKey:pattern]);
            IMP imp = [self methodForSelector:selector];
            void (*func)(id, SEL, NSArray *) = (void *)imp;
            func(self, selector, captures);

            return;
        }
    }
}

- (NSDictionary *)deepLinkPatterns
{
    return @{
             @"//victorious/(\\d+)/sequence"                : @"handleSequenceURL:",
             @"//victorious/(\\d+)/profile/(\\d+)"          : @"handleProfileURL:",
             @"//victorious/(\\d+)/conversation"            : @"handleConversationURL:",
             @"//victorious/(\\d+)/others/(\\d+)/review"    : @"handleOtherStuffURL:"
             };
}

- (void)handleSequenceURL:(NSArray *)captures
{
    
}

- (void)handleProfileURL:(NSArray *)captures
{
    
}

- (void)handleConversationURL:(NSArray *)captures
{
    
}

- (void)handleOtherStuffURL:(NSArray *)captures
{
    
}

#pragma mark - Location

- (void)initLocationForAPIHeader
{
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
}

- (void)determineLocationForAPIHeader
{
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
}

#pragma mark - CCLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager  stopMonitoringSignificantLocationChanges];
    
    CLLocation *location = [locations lastObject];
    CLLocationDegrees  latitude = location.coordinate.latitude;
    CLLocationDegrees  longitude = location.coordinate.longitude;
    
    self.geoCoder = [[CLGeocoder alloc] init];
    [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         CLPlacemark*       mapLocation = [placemarks firstObject];
         NSString*          header = [NSString stringWithFormat:@"latitude:%#.4f, longitude:%#.4f, country:%@, iso_country_code:%@, state:%@, city:%@, postal_code:%@",
                                      latitude, longitude, mapLocation.country, mapLocation.ISOcountryCode, mapLocation.administrativeArea, mapLocation.locality, mapLocation.postalCode];
         [[[VObjectManager sharedManager] HTTPClient] setDefaultHeader:@"X-Geo-Location" value:header];
     }];
}


@end
