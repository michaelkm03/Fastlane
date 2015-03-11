//
//  VStream+RestKit.h
//  victorious
//
//  Created by Will Long on 9/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStream.h"

@interface VStream (RestKit)

+ (NSArray *)descriptors;

+ (NSString *)entityName;

@end
