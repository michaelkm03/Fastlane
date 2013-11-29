//
//  User+RestKit.h
//  victoriOS
//
//  Created by Will Long on 11/27/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "User.h"
#import "NSManagedObject+EasyFetching.h"

@interface User (RestKit)

+(RKEntityMapping*)entityMapping;
+(RKResponseDescriptor*)descriptor;

@end
