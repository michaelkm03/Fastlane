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
 CoreLocation CLLocationManager object to retrieve / manage location data
 */
@property (nonatomic, readonly) CLLocationManager *locationManager;

/**
 A placemark that describes the user's current location, if we have it
 */
@property (nonatomic, readonly) CLPlacemark *locationPlacemark;

/**
 The user's current location, if we have it
 */
@property (nonatomic, readonly) CLLocation *location;

/**
 Delegate object to handle forwarding of CLLocation information
 */
@property (nonatomic, weak) id<VLocationManagerDelegate> delegate;

/**
 Singleton instance of VLocationInfo object
 
 @return Instance of VLocationInfo
 */
+ (instancetype)sharedInstance;

/**
 Class method that reports location services permission
 
 @return BOOL value indicating access permission
 */
+ (BOOL)haveLocationServicesPermission;

/**
 Method to start location monitoring
 */
- (void)startLocationChangesMonitoring;

/**
 Method to stop location monitoring
 */
- (void)stopLocationChangesMonitoring;

@end
