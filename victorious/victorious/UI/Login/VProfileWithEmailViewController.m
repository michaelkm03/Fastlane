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

    if ([CLLocationManager locationServicesEnabled])
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
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
        self.locationTextField.text = ABCreateStringWithAddressDictionary(mapLocation.addressDictionary, YES);
        self.geoCoder = nil;
    }];
}

@end
