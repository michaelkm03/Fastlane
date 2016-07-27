//
//  VNotificationSettingsTestDelegate.m
//  victorious
//
//  Created by Patrick Lynch on 11/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNotificationSettingsTestDelegate.h"

@implementation VNotificationSettingsTestDelegate

- (void)onDeviceDidRegisterWithOS
{
    self.onDeviceDidRegisterWithOSCalled = YES;
}

- (void)onError:(NSError *)error
{
    self.error = error;
}

- (void)onDeviceWillRegisterWithServer
{
    self.onDeviceWillRegisterWithServerCalled = YES;
}

@end
