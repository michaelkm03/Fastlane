//
//  VCategory+RestKit.h
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VCategory.h"
#import "NSManagedObject+EasyFetching.h"

@interface VCategory (RestKit)

+ (RKResponseDescriptor*)descriptor;

@end
