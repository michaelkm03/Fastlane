//
//  Comment+RestKit.h
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VComment.h"
#import "NSManagedObject+EasyFetching.h"

@interface VComment (RestKit)

+ (RKResponseDescriptor*)descriptor;
+ (RKResponseDescriptor*)getAllDescriptor;

@end
