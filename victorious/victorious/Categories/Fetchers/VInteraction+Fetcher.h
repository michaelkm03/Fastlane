//
//  VInteraction+Fetcher.h
//  victoriOS
//
//  Created by Will Long on 12/18/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VInteraction.h"

@interface VInteraction (Fetcher)

+ (NSArray*)orderedInteractionsForNode:(VNode*)node;

@end
