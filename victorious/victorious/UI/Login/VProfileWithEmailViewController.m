//
//  VProfileWithEmailViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileWithEmailViewController.h"
#import "VUser.h"
#import "VConstants.h"

#import "VObjectManager+Login.h"

@import CoreLocation;
@import AddressBookUI;

@interface VProfileWithEmailViewController ()   <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager*    locationManager;
@property (nonatomic, strong) CLGeocoder*           geoCoder;
@end

@implementation VProfileWithEmailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.usernameTextField becomeFirstResponder];

    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.locationManager  stopMonitoringSignificantLocationChanges];
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    
    [[VObjectManager sharedManager] updateVictoriousWithEmail:nil
                                                     password:nil
                                                         name:self.usernameTextField.text
                                              profileImageURL:nil
                                                     location:self.locationTextField.text
                                                      tagline:self.taglineTextView.text
                                                 successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
     {
         VLog(@"Succeeded with objects: %@", resultObjects);
     }
                                                    failBlock:^(NSOperation* operation, NSError* error)
     {
         VLog(@"Failed with error: %@", error);
     }];

    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CCLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager  stopMonitoringSignificantLocationChanges];
    
    CLLocation *location = [locations lastObject];
    
    self.geoCoder = [[CLGeocoder alloc] init];
    [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
    {
        CLPlacemark*    mapLocation = [placemarks firstObject];
        NSMutableDictionary*    locationDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
        
        if (mapLocation.locality)
            [locationDictionary setObject:mapLocation.locality forKey:(__bridge NSString *)kABPersonAddressCityKey];

        if (mapLocation.administrativeArea)
            [locationDictionary setObject:mapLocation.administrativeArea forKey:(__bridge NSString *)kABPersonAddressStateKey];

        [locationDictionary setObject:[[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleCountryCode] forKey:(__bridge NSString *)kABPersonAddressCountryCodeKey];
        self.locationTextField.text = ABCreateStringWithAddressDictionary(locationDictionary, NO);
    }];
}

@end
