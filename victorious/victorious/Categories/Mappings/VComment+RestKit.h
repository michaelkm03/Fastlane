//
//  Comment+RestKit.h
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VComment.h"
#import "NSManagedObject+RestKit.h"

@interface VComment (RestKit)

+ (RKResponseDescriptor*)descriptor;
+ (RKResponseDescriptor*)getAllDescriptor;
+ (RKResponseDescriptor*)getAllPaginationDescriptor;
+ (RKResponseDescriptor*)fetchDescriptor;

@end
