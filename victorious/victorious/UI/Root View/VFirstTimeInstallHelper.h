//
//  VFirstTimeInstallHelper.h
//  victorious
//
//  Created by Lawrence Leach on 3/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDependencyManager, VSequence, VFirstTimeInstallHelper;

extern NSString * const kFTUSequenceURLPath;

@interface VFirstTimeInstallHelper : NSObject

/**
 Singleton instance of VFirstTimeInstallHelper object
 
 @return Instance of VFirstTimeInstallHelper
 */
+ (instancetype)sharedInstance;

/**
 Class method that reports if the Welcome video has been shown.
 
 @return BOOL indicating if user has previously viewed the app welcome video or not
 */
- (BOOL)hasBeenShown;

/**
 Reports if a media url exists in order to show the First-time user video
 
 @return BOOl indicating if a media url exists or not.
 */
- (BOOL)hasMediaUrl;

/**
 Sets the NSUserDefault that reports if the first time user video has been shown
 */
- (void)savePlaybackDefaults;

/**
 VSequence object that contains media url
 */
@property (nonatomic, strong) VSequence *sequence;

/**
 Dependency manager used to access app components
 */
@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
 Url referencing video to be played
 */
@property (nonatomic, strong) NSURL *mediaUrl;

@end
