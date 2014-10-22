//
//  VTracking+RestKit.h
//  victorious
//
//  Created by Patrick Lynch on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VTracking.h"

@class RKResponseDescriptor;

@interface VTracking (RestKit)

+ (RKResponseDescriptor *)descriptor;

+ (BOOL)urlsAreValid:(id)property;

@end
