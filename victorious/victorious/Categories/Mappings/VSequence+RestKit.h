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

+ (RKResponseDescriptor*)sequenceListDescriptor;
+ (RKResponseDescriptor*)sequenceFullDataDescriptor;
+ (RKResponseDescriptor*)sequenceListPaginationDescriptor;

@end
