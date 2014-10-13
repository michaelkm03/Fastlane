//
//  VExperimentManager.m
//  victorious
//
//  Created by Will Long on 6/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSettingManager.h"
#import <AVFoundation/AVAssetExportSession.h>
#import <AVFoundation/AVCaptureSession.h>

#import "VObjectManager+Environment.h"
#import "VEnvironment.h"
#import "VVoteType.h"

//Settings
NSString * const   kVCaptureVideoQuality               =   @"capture";
NSString * const   kVExportVideoQuality                =   @"remix";

NSString * const   kVRealtimeCommentsEnabled           =   @"realtimeCommentsEnabled";
NSString * const   kVMemeAndQuoteEnabled               =   @"memeAndQuoteEnabled";

NSString * const   VSettingsChannelsEnabled = @"channelsEnabled";
NSString * const   VSettingsMarqueeEnabled = @"marqueeEnabled";

//Experiments
NSString * const VExperimentsRequireProfileImage = @"require_profile_image";

//URLs
NSString * const   kVTermsOfServiceURL                 =   @"url.tos";
NSString * const   kVAppStoreURL                       =   @"url.appstore";
NSString * const   kVPrivacyUrl                        =   @"url.privacy";

@implementation VSettingManager

+ (instancetype)sharedManager
{
    static  VSettingManager  *sharedManager;
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
        NSURL  *defaultExperimentsURL =   [[NSBundle mainBundle] URLForResource:@"defaultSettings" withExtension:@"plist"];
        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfURL:defaultExperimentsURL]];
        
        [self clearVoteTypes];
    }
    
    return self;
}

- (void)clearVoteTypes
{
    _voteTypes = @[];
}

- (void)updateSettingsWithVoteTypes:(NSArray *)voteTypes
{
    // Error checking
    if ( voteTypes == nil || voteTypes.count == 0 )
    {
        return;
    }
    
    // Check that only objects of type VVoteType are accepted
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isMemberOfClass:[VVoteType class]];
    }];
    _voteTypes = [voteTypes filteredArrayUsingPredicate:predicate];
    
    // Sort by display order
    _voteTypes = [_voteTypes sortedArrayWithOptions:0 usingComparator:^NSComparisonResult( VVoteType *v1, VVoteType *v2) {
        return [v1.display_order compare:v2.display_order];
    }];
    
    [self cacheVoteTypeImages:_voteTypes];
}

- (void) cacheVoteTypeImages:(NSArray *)voteTypes
{
    [voteTypes enumerateObjectsUsingBlock:^(VVoteType *voteType, NSUInteger i, BOOL *stop) {
        
        if ( [voteType.images isKindOfClass:[NSArray class]] )
        {
            
            NSArray* images = (NSArray*)voteType.images;
            [images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                NSString *path = [NSString stringWithFormat:@"vote_types/%@/sprites", voteType.name];
                NSString *fullPath = [self getCachesDirectoryPathForPath:path];
                
            }];
        }
        
    }];
}

- (NSString *) getCachesDirectoryPathForPath:(NSString*)path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    NSString *compoundPath = [cachePath stringByAppendingPathComponent:path];
    
    BOOL isDirectory;
    BOOL doesFileExist = [[NSFileManager defaultManager] fileExistsAtPath:compoundPath isDirectory:&isDirectory];
    if ( doesFileExist && !isDirectory ) {
        NSError *error;
        BOOL didCreateDirectory = [[NSFileManager defaultManager] createDirectoryAtPath:compoundPath
                                                            withIntermediateDirectories:YES
                                                                             attributes:nil
                                                                                  error:&error];
        if ( !didCreateDirectory ) {
            return nil;
        }
    }
    
    return compoundPath;
}

- (void)updateSettingsWithDictionary:(NSDictionary *)dictionary
{
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
     }];
}

- (NSURL *)urlForKey:(NSString *)key
{
    NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    NSURL *url;
    
    //If it contains :// its a valid URL
    if ([path rangeOfString:@"://"].length)
    {
        url = [NSURL URLWithString:path];
    }
    else
    {
        url = [[VObjectManager currentEnvironment].baseURL URLByAppendingPathComponent:path];
    }
    
    return url;
}

- (NSString *)emailForKey:(NSString *)key
{
    return nil;
}

- (BOOL)settingEnabledForKey:(NSString *)settingKey
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:settingKey] boolValue];
}

- (NSInteger)variantForExperiment:(NSString *)experimentKey
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:experimentKey] integerValue];
}

- (NSString *)exportVideoQuality
{
    NSString   *value   =   [[NSUserDefaults standardUserDefaults] objectForKey:kVExportVideoQuality];
    
    if ([value isEqualToString:@"low"])
    {
        return  AVAssetExportPresetLowQuality;
    }
    else if ([value isEqualToString:@"medium"])
    {
        return  AVAssetExportPresetMediumQuality;
    }
    else if ([value isEqualToString:@"high"])
    {
        return  AVAssetExportPresetHighestQuality;
    }
    else
    {
        return AVAssetExportPresetMediumQuality;
    }
}

- (NSString *)captureVideoQuality
{
    NSString   *value   =   [[NSUserDefaults standardUserDefaults] objectForKey:kVCaptureVideoQuality];
    
    if ([value isEqualToString:@"low"])
    {
        return  AVCaptureSessionPresetLow;
    }
    else if ([value isEqualToString:@"medium"])
    {
        return  AVCaptureSessionPresetMedium;
    }
    else if ([value isEqualToString:@"high"])
    {
        return  AVCaptureSessionPresetHigh;
    }
    else
    {
        return AVCaptureSessionPresetMedium;
    }
}

@end
