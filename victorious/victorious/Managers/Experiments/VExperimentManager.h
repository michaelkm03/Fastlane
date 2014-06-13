//
//  VExperimentManager.h
//  victorious
//
//  Created by Will Long on 6/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

extern  NSString*   const   kVCaptureVideoQuality;
extern  NSString*   const   kVExportVideoQuality;

@interface VExperimentManager : NSObject

+ (VExperimentManager *)sharedManager;

- (void)updateExperimentsWithDictionary:(NSDictionary *)dictionary;
- (NSInteger)variantForExperiment:(NSString*)experimentKey;

- (NSString *)exportVideoQuality;
- (NSString *)captureVideoQuality;

@end
