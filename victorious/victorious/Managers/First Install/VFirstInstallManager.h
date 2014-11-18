//
//  VFirstInstallManager.h
//  victorious
//
//  Created by Patrick Lynch on 11/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VFirstInstallManager : NSObject

/**
 Check if this is the first time the app has been installed and track the event.
 */
- (void)reportFirstInstall;

/**
 Check if this is the first time the app has been installed and track the event
 using the now-deprecated tracking methods and old install detection.
 */
- (void)reportFirstInstallWithOldTracking;

@end
