//
//  VExperimentManager.h
//  victorious
//
//  Created by Will Long on 6/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

//Settings
extern  NSString*   const   kVCaptureVideoQuality;
extern  NSString*   const   kVExportVideoQuality;
extern  NSString*   const   kVRealtimeCommentsEnabled;
extern  NSString*   const   kVMemeAndQuoteEnabled;
//URLs
extern  NSString*   const   kVTermsOfServiceURL;
extern  NSString*   const   kVPrivacyUrl;

extern  NSString*   const   kVAppStoreURL;
extern  NSString*   const   kVChannelURLSupport;

@interface VSettingManager : NSObject

+ (instancetype)sharedManager;

- (void)updateSettingsWithDictionary:(NSDictionary *)dictionary;
- (NSInteger)variantForExperiment:(NSString*)experimentKey;
- (BOOL)settingEnabledForKey:(NSString*)settingKey;

- (NSURL*)urlForKey:(NSString*)key;

- (NSString *)exportVideoQuality;
- (NSString *)captureVideoQuality;

@end
