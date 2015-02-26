//
//  VLocationManager.m
//  victorious
//
//  Created by Lawrence Leach on 2/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLocationManager.h"
@import AddressBookUI;

#define EnableLocationInfoLogging 0  // Set this to 1 in order to view location details in the console log window

@interface VLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, assign, readwrite) BOOL permissionGranted;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *postalCode;

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
    self = [super init];
    if (self)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    
    return self;
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
    [manager  stopUpdatingLocation];
    
    __block CLPlacemark *locationPlacemark;
    __weak typeof(self) welf = self;
    CLLocation *location = [locations lastObject];
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         locationPlacemark = [placemarks firstObject];
         welf.postalCode = locationPlacemark.postalCode;
         
         welf.latitude = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
         welf.longitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
         
         // Send to delegate
         if ([welf.delegate respondsToSelector:@selector(didReceiveLocations:withPlacemark:withLocationManager:)])
         {
             [welf.delegate didReceiveLocations:locations withPlacemark:locationPlacemark withLocationManager:welf];
         }
     }];
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
