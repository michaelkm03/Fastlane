//
//  VFirstInstallManager.h
//  victorious
//
//  Created by Patrick Lynch on 11/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const VAppInstalledOldTrackingDefaultsKey;
extern NSString * const VAppInstalledDefaultsKey;

@interface VFirstInstallManager : NSObject

/**
 Check if this is the first time the app has been installed and track the event.
 */
- (void)reportFirstInstall;

@end
