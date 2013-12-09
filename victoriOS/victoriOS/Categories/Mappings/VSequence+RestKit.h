//
//  Sequence+RestKit.h
//  victoriOS
//
//  Created by Will Long on 11/27/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VSequence.h"
#import "VComment+RestKit.h"
#import "VNode+RestKit.h"

@interface VSequence (RestKit)

+ (RKResponseDescriptor*)sequenceListDescriptor;
+ (RKResponseDescriptor*)sequenceFullDataDescriptor;

@end
