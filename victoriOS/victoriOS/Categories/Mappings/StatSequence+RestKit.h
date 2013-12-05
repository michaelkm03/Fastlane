//
//  StatSequence+RestKit.h
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "StatSequence.h"
#import "StatInteraction+RestKit.h"

@interface StatSequence (RestKit)

+ (RKResponseDescriptor*)gamesPlayedDescriptor;
+ (RKResponseDescriptor*)gameStatsDescriptor;

@end
