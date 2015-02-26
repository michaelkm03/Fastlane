//
//  VLocationManager.h
//  victorious
//
//  Created by Lawrence Leach on 2/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@class VLocationManager;

@protocol VLocationManagerDelegate <NSObject>

@optional
/**
 Returns an NSArray of locations as a result of a CoreLocation call
 
 @param geoCoder     CLGeocoder object
 @param locations    NSArray of CLLocation objects
 @param locationInfo Instance of VLocationInfo
 */
- (void)didReceiveLocations:(NSArray *)locations withPlacemark:(CLPlacemark *)placemark withLocationManager:(VLocationManager *)locationManager;

@end

@interface VLocationManager : NSObject

/**
 Read-only property to report on permission to use location information
 */
@property (nonatomic, readonly) BOOL permissionGranted;

/**
 CoreLocation CLLocationManager object to retrieve / manage location data
 */
@property (nonatomic, strong) CLLocationManager *locationManager;

/**
 Delegate object to handle forwarding of CLLocation information
 */
@property (nonatomic, weak) id<VLocationManagerDelegate>delegate;

/**
 Singleton instance of VLocationInfo object
 
 @return Instance of VLocationInfo
 */
+ (instancetype)sharedInstance;

/**
 Formatted string of location information
 
 @return Location information formatted for backend HTTP header
 */
- (NSString *)httpFormattedLocationString;

/**
 Method to start location monitoring
 */
- (void)startLocationChangesMonitoring;

/**
 Method to stop location monitoring
 */
- (void)stopLocationChangesMonitoring;

@end
