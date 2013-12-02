//
//  Comment+RestKit.h
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "Comment.h"
#import "NSManagedObject+EasyFetching.h"

@interface Comment (RestKit)

+ (RKResponseDescriptor*)descriptor;

@end
