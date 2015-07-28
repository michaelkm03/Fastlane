//
//  NSIndexSet+Convenience.h
//  victorious
//
//  Created by Michael Sena on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexSet (Convenience)

/**
 *  Generates an array of indexpaths from the index set with the passed section.
 */
- (NSArray *)indexPathsFromIndexesWithSection:(NSInteger)section;

@end
