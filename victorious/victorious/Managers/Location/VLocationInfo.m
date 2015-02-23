//
//  VLocationInfo.m
//  victorious
//
//  Created by Lawrence Leach on 2/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLocationInfo.h"
@import AddressBookUI;

#define EnableLocationInfoLogging 0  // Set this to 1 in order to view location details in the console log

@interface VLocationInfo () <CLLocationManagerDelegate>

@property (nonatomic, assign, readwrite) BOOL permissionGranted;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *postalCode;

@end

@implementation VLocationInfo

+ (instancetype)sharedInstance
{
    static  VLocationInfo  *sharedInstance;
    static  dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,
                  ^{
                      sharedInstance = [[self alloc] init];
                      
                  });
    
    return sharedInstance;
}

- (instancetype)init
{
    self    =   [super init];
    if (self)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    
    return self;
}

- (NSString *)httpFormattedLocationString
{
    // I'm leaving this in here so we can confirm that requests
#if DEBUG && EnableLocationInfoLogging
    VLog(@"\n\nDevice Location Details\n-----------------------\nLatitude: %@,\nLongitude: %@,\nPostal Code: %@\n\n", self.latitude, self.longitude, self.postalCode);
#warning Location logging is enabled. Please disable it once when you're finished debugging.
#endif
    return [NSString stringWithFormat:@"latitude:%@, longitude:%@, postal_code:%@", self.latitude, self.longitude, self.postalCode];
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
    [manager  stopUpdatingLocation];
    
    CLLocation *location = [locations lastObject];
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         CLPlacemark *mapLocation = [placemarks firstObject];
         self.postalCode = mapLocation.postalCode;
         self.latitude = [[NSNumber numberWithDouble:mapLocation.location.coordinate.latitude] stringValue];
         self.longitude = [[NSNumber numberWithDouble:mapLocation.location.coordinate.longitude] stringValue];
     }];
    
    // Send to delegate
    if ([self.delegate respondsToSelector:@selector(didReceiveLocations:withLocationInfo:)])
    {
        [self.delegate didReceiveLocations:locations withLocationInfo:self];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        self.permissionGranted = YES;
        [manager startUpdatingLocation];
    }
}

@end
