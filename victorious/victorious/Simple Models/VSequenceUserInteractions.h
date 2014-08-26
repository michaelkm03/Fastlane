//
//  VSequenceUserInteractions.h
//  victorious
//
//  Created by Michael Sena on 8/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSequenceUserInteractions : NSObject

+ (instancetype)sequenceUserInteractionsWithPayload:(NSDictionary *)payload;

@property (nonatomic, assign, readonly) BOOL hasReposted;

@end
