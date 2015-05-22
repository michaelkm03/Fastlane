//
//  VPermissionMicrophone.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPermissionMicrophone.h"

@import AVFoundation;

@implementation VPermissionMicrophone

- (VPermissionState)permissionState
{
#if TARGET_IPHONE_SIMULATOR
    return VPermissionUnsupported;
#endif
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    AVAudioSessionRecordPermission systemState = [audioSession recordPermission];
    switch (systemState)
    {
        case AVAudioSessionRecordPermissionDenied:
            return VPermissionStateSystemDenied;
        case AVAudioSessionRecordPermissionGranted:
            return VPermissionStateAuthorized;
        case AVAudioSessionRecordPermissionUndetermined:
            return VPermissionStateUnknown;
    }
}

- (void)requestSystemPermissionWithCompletion:(VPermissionRequestCompletionHandler)completion
{
    // Completion handler is required
    NSParameterAssert(completion != nil);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession requestRecordPermission:^(BOOL granted)
     {
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            completion(granted, granted ? VPermissionStateAuthorized : VPermissionStateSystemDenied, nil);
                        });
     }];
}

- (NSString *)messageWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *message = [dependencyManager stringForKey:@"microphonePermission.message"];
    return NSLocalizedString(message, @"");
}

@end
