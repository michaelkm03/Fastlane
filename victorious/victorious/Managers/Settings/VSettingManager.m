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
#import "VFileCache.h"
#import "VFileCache+VVoteType.h"
#import "VVoteType+Fetcher.h"
#import "VTracking.h"
#import "VPurchaseManager.h"

//Settings
NSString * const kVCaptureVideoQuality =   @"capture";
NSString * const kVExportVideoQuality =   @"remix";

NSString * const kVRealtimeCommentsEnabled =   @"realtimeCommentsEnabled";
NSString * const kVMemeAndQuoteEnabled =   @"memeAndQuoteEnabled";

NSString * const VSettingsTemplateCEnabled = @"template_c_enabled - 2";
NSString * const VSettingsChannelsEnabled = @"channels_enabled";
NSString * const VSettingsMarqueeEnabled = @"marqueeEnabled";

//Experiments
NSString * const VExperimentsRequireProfileImage = @"require_profile_image";
NSString * const VExperimentsHistogramEnabled = @"histogram_enabled";
NSString * const VExperimentsPauseVideoWhenCommenting = @"pause_video_when_commenting";
NSString * const VExperimentsClearVideoBackground = @"clear_video_background";

//Monetization
NSString * const kLiveRailPublisherId = @"monetization.LiveRailsPublisherID";
NSString * const kOpenXVastTag = @"monetization.OpenXVastTag";

//URLs
NSString * const kVTermsOfServiceURL = @"url.tos";
NSString * const kVAppStoreURL = @"url.appstore";
NSString * const kVPrivacyUrl = @"url.privacy";

@interface VSettingManager()

@property (nonatomic, strong) VFileCache *fileCache;
@property (nonatomic, readwrite) NSArray *voteTypes;

@end

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
        
        self.fileCache = [[VFileCache alloc] init];
        
        [self clearVoteTypes];
    }
    
    return self;
}

- (void)clearVoteTypes
{
    self.voteTypes = @[];
}

- (void)updateSettingsWithAppTracking:(VTracking *)tracking
{
    _applicationTracking = tracking;
}

- (void)updateSettingsWithVoteTypes:(NSArray *)voteTypes
{
    // Error checking
    if ( voteTypes == nil || voteTypes.count == 0 )
    {
        return;
    }
    
    // Check that only objects of type VVoteType are accepted
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(VVoteType *voteType, NSDictionary *bindings)
                              {
                                  return [voteType isMemberOfClass:[VVoteType class]] &&
                                        voteType.containsRequiredData &&
                                        voteType.hasValidTrackingData;
                              }];
    self.voteTypes = [voteTypes filteredArrayUsingPredicate:predicate];
    
#warning testing only
    [voteTypes enumerateObjectsUsingBlock:^(VVoteType *voteType, NSUInteger idx, BOOL *stop)
    {
        NSUInteger order = voteType.displayOrder.unsignedIntegerValue;
        if ( order == 1 )
        {
            voteType.isPaid = @YES;
            voteType.productIdentifier = [NSString stringWithFormat:@"com.getvictorious.eatyourkimchi.testpurchase.000%lu", (unsigned long)order];
            *stop = YES;
        }
    }];
    
    [self.fileCache cacheImagesForVoteTypes:voteTypes];
    NSArray *productIdentifiers = [VVoteType productIdentifiersFromVoteTypes:voteTypes];
    [[VPurchaseManager sharedInstance] fetchProductsWithIdentifiers:productIdentifiers success:^(NSArray *products)
    {
        // TODO: Use nil instead of block here, this is fire and forget
    }
                                                          failure:^(NSError *error)
     {
         // TODO: Use nil instead of block here, this is fire and forget
    }];
}

- (void)updateSettingsWithPurchasedProductIdentifier:(NSString *)productIdentifier
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productIdentifier == %@", productIdentifier];
    NSArray *matches = [self.voteTypes filteredArrayUsingPredicate:predicate];
    if ( matches.firstObject != nil && [matches.firstObject isKindOfClass:[VVoteType class]] )
    {
        VVoteType *voteType = matches.firstObject;
        [voteType purchaseWithProductIdentifier:productIdentifier];
    }
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

- (NSString *)fetchMonetizationItemByKey:(NSString *)key
{
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if ([self settingEnabledForKey:key])
    {
        return value;
    }
    
    return @"";
}

@end
