//
//  StatSequence+RestKit.h
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VStatSequence.h"
#import "VStatInteraction+RestKit.h"

@interface VStatSequence (RestKit)

+ (RKResponseDescriptor*)gamesPlayedDescriptor;
+ (RKResponseDescriptor*)gameStatsDescriptor;
+ (RKResponseDescriptor*)createGameDescriptor;

@end
