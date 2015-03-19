//
//  VFirstTimeInstallHelper.h
//  victorious
//
//  Created by Lawrence Leach on 3/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDependencyManager, VSequence, VFirstTimeInstallHelper;

extern NSString * const kFTUSequenceURL;
extern NSString * const kFTUTrackingURLGroup;

@interface VFirstTimeInstallHelper : NSObject

/**
 Class method that reports if the Welcome video has been shown.
 
 @return BOOL indicating if user has previously viewed the app welcome video or not
 */
- (BOOL)hasBeenShown;

/**
 Sets the NSUserDefault that reports if the first time user video has been shown
 */
- (void)savePlaybackDefaults;

@end
