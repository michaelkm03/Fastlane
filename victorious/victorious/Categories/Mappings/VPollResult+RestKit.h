//
//  VPollResult+RestKit.h
//  victorious
//
//  Created by Will Long on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPollResult.h"
#import "NSManagedObject+EasyFetching.h"

@interface VPollResult (RestKit)

+ (RKResponseDescriptor*)descriptor;

+ (RKResponseDescriptor*)createPollResultDescriptor;

@end
