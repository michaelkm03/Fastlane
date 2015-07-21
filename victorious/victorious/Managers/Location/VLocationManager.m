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

@import AddressBookUI;

#define EnableLocationInfoLogging 0  // Set this to 1 in order to view location details in the console log window

@interface VLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, assign, readwrite) BOOL permissionGranted;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *postalCode;
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

- (NSString *)httpFormattedLocationString
{
#if EnableLocationInfoLogging
    VLog(@"\n\nDevice Location Details\n-----------------------\nLatitude: %@,\nLongitude: %@,\nPostal Code: %@\n\n", self.latitude, self.longitude, self.postalCode);
#warning Location logging is enabled. Please disable it once when you're finished debugging.
#endif
    
    NSString *formattedString = @"";
    if (self.latitude != nil && self.longitude != nil)
    {
        if (self.postalCode != nil && ![self.postalCode isEqualToString:@""])
        {
            formattedString = [NSString stringWithFormat:@"latitude:%@, longitude:%@, postal_code:%@", self.latitude, self.longitude, self.postalCode];
        }
        else
        {
            formattedString = [NSString stringWithFormat:@"latitude:%@, longitude:%@", self.latitude, self.longitude];
        }
    }
    return formattedString;
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
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         self.locationPlacemark = [placemarks firstObject];
         self.postalCode = self.locationPlacemark.postalCode;
         
         self.latitude = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
         self.longitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
         
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
        self.permissionGranted = YES;
        [manager startUpdatingLocation];
        [self.permissionsTrackingHelper permissionsDidChange:VTrackingValueLocationDidAllow permissionState:VTrackingValueAuthorized];
    }
    else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
    {
        [self.permissionsTrackingHelper permissionsDidChange:VTrackingValueLocationDidAllow permissionState:VTrackingValueDenied];
    }
}

@end
