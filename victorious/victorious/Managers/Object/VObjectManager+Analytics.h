//
//  VObjectManager+Analytics.h
//  victorious
//
//  Created by Josh Hinman on 7/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"
#import "VAnalyticsConstants.h"

@class VSequence;

@interface VObjectManager (Analytics)

- (NSDictionary *)dictionaryForInstallEventWithDate:(NSDate *)date;
- (NSDictionary *)dictionaryForSessionEventWithDate:(NSDate *)date length:(NSTimeInterval)length;
- (NSDictionary *)dictionaryForSequenceViewWithDate:(NSDate *)date length:(NSTimeInterval)length sequence:(VSequence *)sequence;

/**
 Send an analytics event to the server
 */
- (RKManagedObjectRequestOperation *)addEvents:(NSArray /* NSDictionary */ *)event successBlock:(VSuccessBlock)success failBlock:(VFailBlock)fail;

- (BOOL)trackEventWithUrl:(NSString *)url;

- (BOOL)trackEventWithUrl:(NSString *)url andValues:(NSDictionary *)values;

@end
