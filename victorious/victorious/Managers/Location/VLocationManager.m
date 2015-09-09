//
//  VLocationManager.m
//  victorious
//
//  Created by Lawrence Leach on 2/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLocationManager.h"
#import <CoreLocation/CLAvailability.h>
#import "VPermissionsTrackingHelper.h"
#import "VPermission.h"

@interface VLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, assign, readwrite) BOOL permissionGranted;
@property (nonatomic, readwrite) CLPlacemark *locationPlacemark;
@property (nonatomic, readwrite) CLLocation *location;
@property (nonatomic, strong) VPermissionsTrackingHelper *permissionsTrackingHelper;

@end

@implementation VLocationManager

+ (instancetype)sharedInstance
{
    static  VLocationManager  *sharedInstance;
    static  dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,
                  ^{
                      sharedInstance = [[self alloc] init];
                      
                  });
    
    return sharedInstance;
}

- (instancetype)init
{
    NSAssert([NSThread isMainThread], @"VLocationManager init MUST be called from the main thread since it's creating the shared CLLocationManager");
    self = [super init];
    if (self)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _permissionsTrackingHelper = [[VPermissionsTrackingHelper alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    _locationManager.delegate = nil;
}

+ (BOOL)haveLocationServicesPermission
{
    if ( [CLLocationManager locationServicesEnabled] && ( [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ) )
    {
        return YES;
    }
    return NO;
}

- (CLPlacemark *)lastLocationRetrieved
{
    if (self.locationPlacemark != nil)
    {
        return self.locationPlacemark;
    }
    return nil;
}

#pragma mark - Start / Stop Location Monitoring

- (void)startLocationChangesMonitoring
{
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)stopLocationChangesMonitoring
{
    [self.locationManager  stopMonitoringSignificantLocationChanges];
}

#pragma mark - CCLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    self.location = location;
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         self.locationPlacemark = [placemarks firstObject];
         
         // Send to delegate
         if ([self.delegate respondsToSelector:@selector(didReceiveLocations:withPlacemark:withLocationManager:)])
         {
             [self.delegate didReceiveLocations:locations withPlacemark:self.locationPlacemark withLocationManager:self];
         }
     }];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        [manager startUpdatingLocation];
        [self.permissionsTrackingHelper permissionsDidChange:VTrackingValueLocationDidAllow permissionState:VTrackingValueAuthorized];
    }
    else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
    {
        [self.permissionsTrackingHelper permissionsDidChange:VTrackingValueLocationDidAllow permissionState:VTrackingValueDenied];
    }
}

@end
