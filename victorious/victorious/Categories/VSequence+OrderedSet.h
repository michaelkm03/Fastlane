//
//  VSequence+OrderedSet.h
//  victorious
//
//  Created by Will Long on 9/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSequence.h"

@interface VSequence (OrderedSet)

/**
 *  Adds a comment object to the ordered set.  Note: does not save managed object context
 *
 *  @param value A comment to add to self.comments
 */
- (void)addCommentsObject:(VComment *)value;

@end
