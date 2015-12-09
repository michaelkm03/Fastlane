//
//  VNotificationSettingsViewController.h
//  victorious
//
//  Created by Patrick Lynch on 11/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"

#import <UIKit/UIKit.h>

@interface VNotificationSettingsViewController : UITableViewController <VHasManagedDependencies>

@property (nonatomic, strong) VDependencyManager *dependencyManager; ///< Must be set prior to display

@end

/// Below is only visible to facilitate Swift Integration
@class VNotificationSettings, VNotificationSettingsStateManager;

@interface VNotificationSettingsViewController (SwiftPersistenceIntegration)

@property (nonatomic, strong) NSError *settingsError;
@property (nonatomic, readonly) VNotificationSettingsStateManager *stateManager;
- (void)setSettings:(VNotificationSettings *)settings;

@end
