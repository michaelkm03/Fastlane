//
//  VPermissionsTrackingHelper.h
//  victorious
//
//  Created by Steven F Petteruti on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPermissionsTrackingHelper : NSObject

/**
 Call this whenever your permissions have changed
 
 @param permissionName The tracking value that changed
 @param permissionState The value that the tracking value changed to

 */
- (void)permissionsDidChange:(NSString *)permissionName permissionState:(NSString *)permissionState;

@end
