//
//  VExperimentManager.m
//  victorious
//
//  Created by Will Long on 6/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VExperimentManager.h"
#import <AVFoundation/AVAssetExportSession.h>
#import <AVFoundation/AVCaptureSession.h>

NSString*   const   kVCaptureVideoQuality               =   @"capture";
NSString*   const   kVExportVideoQuality                =   @"remix";

@implementation VExperimentManager

+ (instancetype)sharedManager
{
    static  VExperimentManager*  sharedManager;
    static  dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,
                  ^{
                      sharedManager = [[self alloc] init];
                  });
    
    return sharedManager;
}

- (instancetype)init
{
    self    =   [super init];
    if (self)
    {
        NSURL*  defaultExperimentsURL =   [[NSBundle mainBundle] URLForResource:@"defaultExperiments" withExtension:@"plist"];
        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfURL:defaultExperimentsURL]];
    }
    
    return self;
}

- (void)updateExperimentsWithDictionary:(NSDictionary *)dictionary
{
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
     }];
}

- (NSInteger)variantForExperiment:(NSString*)experimentKey
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:experimentKey] integerValue];
}

- (NSString *)exportVideoQuality
{
    NSString*   value   =   [[NSUserDefaults standardUserDefaults] objectForKey:kVExportVideoQuality];
    
    if ([value isEqualToString:@"low"])
        return  AVAssetExportPresetLowQuality;
    else if ([value isEqualToString:@"medium"])
        return  AVAssetExportPresetMediumQuality;
    else if ([value isEqualToString:@"high"])
        return  AVAssetExportPresetHighestQuality;
    else
        return AVAssetExportPresetMediumQuality;
}

- (NSString *)captureVideoQuality
{
    NSString*   value   =   [[NSUserDefaults standardUserDefaults] objectForKey:kVCaptureVideoQuality];
    
    if ([value isEqualToString:@"low"])
        return  AVCaptureSessionPresetLow;
    else if ([value isEqualToString:@"medium"])
        return  AVCaptureSessionPresetMedium;
    else if ([value isEqualToString:@"high"])
        return  AVCaptureSessionPresetHigh;
    else
        return AVCaptureSessionPresetMedium;
}

@end
