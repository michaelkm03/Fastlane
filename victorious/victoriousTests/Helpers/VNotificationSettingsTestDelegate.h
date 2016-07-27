//
//  VNotificationSettingsTestDelegate.h
//  victorious
//
//  Created by Patrick Lynch on 11/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VNotificationSettingsStateManager.h"

@interface VNotificationSettingsTestDelegate : NSObject <VNotificiationSettingsStateManagerDelegate>

@property (nonatomic, assign) BOOL onDeviceDidRegisterWithOSCalled;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) BOOL onDeviceWillRegisterWithServerCalled;

@end
