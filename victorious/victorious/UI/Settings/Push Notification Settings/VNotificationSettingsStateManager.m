//
//  VNotificationSettingsStateManager.m
//  victorious
//
//  Created by Patrick Lynch on 11/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNotificationSettingsStateManager.h"
#import "VPushNotificationManager.h"
#import "VConstants.h"

/**
 This will log all state changes as well as insert a delay between state
 changes so that you can more easily inspect current state during development.
 */
#define NOTIFICATION_SETTINGS_STATE_LOGGING_ENABLED 0

#if DEBUG && NOTIFICATION_SETTINGS_STATE_LOGGING_ENABLED
#warning Notification settings state logging is enabled!!

static const char *VNotificationSettingsStateNames[] = {
    "VNotificationSettingsStateUninitialized",
    "VNotificationSettingsStateDefault",
    "VNotificationSettingsStateNotRegistered",
    "VNotificationSettingsStateReregistering",
    "VNotificationSettingsStateRegistered",
    "VNotificationSettingsStateRegistrationFailed",
    "VNotificationSettingsStateLoadSettingsSucceeded",
    "VNotificationSettingsStateLoadSettingsFailed",
    "VNotificationSettingsStateDeviceNotFound"
};
#endif

@interface VNotificationSettingsStateManager()

@property (nonatomic, readonly) NSError *errorDeviceNotFound;
@property (nonatomic, readonly) NSError *errorUnknown;
@property (nonatomic, readonly) NSError *errorNotRegistered;

@end

@implementation VNotificationSettingsStateManager

- (instancetype)initWithDelegate:(id<VNotificiationSettingsStateManagerDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        _delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [self stopListeningForRegistrationNotification];
}

- (void)setState:(VNotificationSettingsState)state
{
    if ( _state == state )
    {
        return;
    }
    _state = state;
    
#if DEBUG && NOTIFICATION_SETTINGS_STATE_LOGGING_ENABLED
    [self performSelector:@selector(updateStateOnDelay) withObject:nil afterDelay:1.0f];
}

- (void)updateStateOnDelay
{
    const char *name = VNotificationSettingsStateNames[ self.state ];
    VLog( @">>>>>>> %@", [NSString stringWithCString:name encoding:NSUTF8StringEncoding] );

#endif
    
    switch (_state)
    {
        case VNotificationSettingsStateDefault:
            // Determine if user is registered and continue to next state accordingly
            if ( [VPushNotificationManager sharedPushNotificationManager].isRegisteredForPushNotifications )
            {
                self.state = VNotificationSettingsStateRegistered;
            }
            else
            {
                self.state = VNotificationSettingsStateNotRegistered;
            }
            break;
            
        case VNotificationSettingsStateRegistered:
            // Stop listening for the the notification that device was registered and load settings from server
            [self stopListeningForRegistrationNotification];
            [self.delegate onDeviceDidRegisterWithOS];
            break;
            
        case VNotificationSettingsStateNotRegistered:
            // Show the 'not enabled' error in the table view and start listening for notification
            // that indicates notifications were enabled
            [self startListeningForRegistrationNotification];
            [self.delegate onError:self.errorNotRegistered];
            break;
            
        case VNotificationSettingsStateLoadSettingsSucceeded:
            // Clear any error and reload to display the settings
            [self.delegate onErrorResolved];
            break;
            
        case VNotificationSettingsStateRegistrationFailed:
        case VNotificationSettingsStateLoadSettingsFailed:
            // Show failure station with message describing unknown error
            [self.delegate onError:self.errorUnknown];
            break;
            
        case VNotificationSettingsStateDeviceNotFound:
            // The OS has told us that the device is registered for push notifications, but the server is missing
            // the APNs token required to make it work.  So, we'll send it:
            self.state = VNotificationSettingsStateReregistering;
            break;
            
        case VNotificationSettingsStateReregistering:
            [self.delegate onDeviceWillRegisterWithServer];
            [self sendToken];
            break;
            
        case VNotificationSettingsStateUninitialized:
        default:
            break;
    }
}

- (void)startListeningForRegistrationNotification
{
    [self stopListeningForRegistrationNotification];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidRegisterForPushNotifications:)
                                                 name:VPushNotificationManagerDidRegister
                                               object:nil];
}

- (void)stopListeningForRegistrationNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VPushNotificationManagerDidRegister object:nil];
}

- (NSError *)errorNotRegistered
{
    return [NSError errorWithDomain:NSLocalizedString( @"ErrorPushNotificationsNotEnabled", nil ) code:kErrorCodeUserNotRegistered userInfo:nil];
}

- (NSError *)errorDeviceNotFound
{
    return [NSError errorWithDomain:NSLocalizedString( @"ErrorPushNotificationsNotEnabled", nil ) code:kErrorCodeDeviceNotFound userInfo:nil];
}

- (NSError *)errorUnknown
{
    return [NSError errorWithDomain:NSLocalizedString( @"ErrorPushNotificationsUnknown", nil ) code:-1 userInfo:nil];
}

- (void)userDidRegisterForPushNotifications:(NSNotification *)notification
{
    self.state = VNotificationSettingsStateRegistered;
}

- (void)sendToken
{
    VPushNotificationManager *pushNotificationManager = [VPushNotificationManager sharedPushNotificationManager];
    [pushNotificationManager sendTokenWithSuccessBlock:^
     {
         self.state = VNotificationSettingsStateRegistered;
     }
                                             failBlock:^(NSError *error)
     {
         self.state = VNotificationSettingsStateRegistrationFailed;
     }];
}

@end
