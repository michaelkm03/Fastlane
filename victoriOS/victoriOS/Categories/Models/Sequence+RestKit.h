//
//  Sequence+RestKit.h
//  victoriOS
//
//  Created by Will Long on 11/27/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "Sequence.h"
#import "Comment+RestKit.h"
#import "Node+RestKit.h"

@interface Sequence (RestKit)

+(RKResponseDescriptor*)sequenceListDescriptor;
+(RKResponseDescriptor*)sequenceInfoDescriptor;

@end
