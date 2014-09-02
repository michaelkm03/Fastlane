//
//  VNode+Fetcher.h
//  victoriOS
//
//  Created by Will Long on 12/18/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VNode.h"

@interface VNode (Fetcher)

- (NSArray*)firstAnswers;
- (VAsset*)firstAsset;

- (NSArray*)orderedInteractions;

- (BOOL)isPoll;

@end
