//
//  VFirstInstallManager.h
//  victorious
//
//  Created by Patrick Lynch on 3/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const VAppInstalledOldTrackingDefaultsKey;
extern NSString * const VAppInstalledDefaultsKey;

@interface VFirstInstallManager : NSObject

@property (nonatomic, assign, readonly) BOOL hasFirstInstallBeenTracked;

- (void)reportFirstInstall;

@end
