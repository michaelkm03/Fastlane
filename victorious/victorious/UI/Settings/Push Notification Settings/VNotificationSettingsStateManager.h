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
    VNotificationSettingsStateReregistering,
    VNotificationSettingsStateRegistered,
    VNotificationSettingsStateRegistrationFailed,
    VNotificationSettingsStateLoadSettingsSucceeded,
    VNotificationSettingsStateLoadSettingsFailed,
    VNotificationSettingsStateDeviceNotFound
};

@class VNotificationSettingsStateManager;

@protocol VNotificiationSettingsStateManagerDelegate <NSObject>

- (void)onDeviceDidRegisterWithOS;
- (void)onError:(NSError *)error;
- (void)onErrorResolved;
- (void)onDeviceWillRegisterWithServer;

@end

/**
 * Manages state of device registration for push  notifications
 */
@interface VNotificationSettingsStateManager : NSObject

- (instancetype)initWithDelegate:(id<VNotificiationSettingsStateManagerDelegate>)delegate;

@property (nonatomic, weak) id<VNotificiationSettingsStateManagerDelegate> delegate;
@property (nonatomic, assign) VNotificationSettingsState state;

@end
