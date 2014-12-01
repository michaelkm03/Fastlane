//
//  VNotificationSettingsStateManager.h
//  victorious
//
//  Created by Patrick Lynch on 11/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM( NSInteger, VNotificationSettingsState )
{
    VNotificationSettingsStateUninitialized,
    VNotificationSettingsStateDefault,
    VNotificationSettingsStateNotRegistered,
    VNotificationSettingsStateRegistered,
    VNotificationSettingsStateRegistrationFailed,
    VNotificationSettingsStateLoadSettingsFailed,
    VNotificationSettingsStateDeviceNotFound
};

@class VNotificationSettingsStateManager;

@protocol VNotificiationSettingsStateManagerDelegate <NSObject>

- (void)onDeviceDidRegisterWithOS;
- (void)onError:(NSError *)error;
- (void)onDeviceWillRegisterWithServer;

@end

/**
 * Manages state of device registration for push  notifications
 */
@interface VNotificationSettingsStateManager : NSObject

- (instancetype)initWithDelegate:(id<VNotificiationSettingsStateManagerDelegate>)delegate;

/**
 Resets back to default state.
 */
- (void)reset;

/**
 Allows state manager to react by updating state according to the
 type of error received.
 */
- (void)errorDidOccur:(NSError *)error;

/**
 Get the current state of notification settings.
 */
@property (nonatomic, assign, readonly) VNotificationSettingsState state;

@property (nonatomic, weak) id<VNotificiationSettingsStateManagerDelegate> delegate;

@end
