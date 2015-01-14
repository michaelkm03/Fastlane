//
//  VExperimentManager.h
//  victorious
//
//  Created by Will Long on 6/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVoteSettings.h"

//Settings
extern NSString * const kVCaptureVideoQuality;
extern NSString * const kVExportVideoQuality;
extern NSString * const kVRealtimeCommentsEnabled;
extern NSString * const kVMemeAndQuoteEnabled;
extern NSString * const VSettingsChannelsEnabled;
extern NSString * const VSettingsMarqueeEnabled;
extern NSString * const VSettingsTemplateCEnabled;
//Experiments
extern NSString * const VExperimentsRequireProfileImage;
extern NSString * const VExperimentsPauseVideoWhenCommenting;
extern NSString * const VExperimentsClearVideoBackground;

//Monetization
extern NSString * const kLiveRailPublisherId;
extern NSString * const kOpenXVastTag;

//URLs
extern NSString * const kVTermsOfServiceURL;
extern NSString * const kVPrivacyUrl;

extern NSString * const kVAppStoreURL;
extern NSString * const kVChannelURLSupport;

@class VTracking;

@interface VSettingManager : NSObject

+ (instancetype)sharedManager;

- (void)updateSettingsWithDictionary:(NSDictionary *)dictionary;
- (NSInteger)variantForExperiment:(NSString *)experimentKey;
- (BOOL)settingEnabledForKey:(NSString *)settingKey;

- (NSURL *)urlForKey:(NSString *)key;

- (NSString *)exportVideoQuality;
- (NSString *)captureVideoQuality;

- (void)updateSettingsWithAppTracking:(VTracking *)tracking;

- (NSString *)fetchMonetizationItemByKey:(NSString *)key;

@property (nonatomic, readonly) VTracking *applicationTracking;
@property (nonatomic, readonly) VVoteSettings *voteSettings;

@end
