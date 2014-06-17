//
//  NSIndexSet+Map.h
//  victorious
//
//  Created by Josh Hinman on 6/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexSet (Map)

- (NSArray *)map:(id(^)(NSUInteger))mapBlock;

@end
