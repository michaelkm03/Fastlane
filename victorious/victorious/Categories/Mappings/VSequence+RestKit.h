//
//  Sequence+RestKit.h
//  victoriOS
//
//  Created by Will Long on 11/27/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VSequence.h"
#import "NSManagedObject+RestKit.h"

@interface VSequence (RestKit)

+ (NSArray *)descriptors;

/**
 A mapping that includes no "major" relationships, such as users, comments or other users.
 This is provided to avoid recusive mappings when user objects are a child of a sequence
 or other such relationships.
 */
+ (RKEntityMapping *)simpleMapping;

@end
