//
//  VSequenceUserInteractions.m
//  victorious
//
//  Created by Michael Sena on 8/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSequenceUserInteractions.h"

@interface VSequenceUserInteractions ()

@property (nonatomic, assign, readwrite) BOOL hasReposted;

@end

static NSString *const kVHasRepostedKey = @"has_reposted";

@implementation VSequenceUserInteractions

+ (instancetype)sequenceUserInteractionsWithPayload:(NSDictionary *)payload
{
    VSequenceUserInteractions *userIteractionsModel = [[VSequenceUserInteractions alloc] init];
    
    userIteractionsModel.hasReposted = [payload[kVHasRepostedKey] isKindOfClass:[NSNumber class]] ? [payload[kVHasRepostedKey] boolValue] : NO;
    
    return userIteractionsModel;
}

@end
