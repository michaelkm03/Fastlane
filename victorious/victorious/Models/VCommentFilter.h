//
//  VCommentFilter.h
//  victorious
//
//  Created by Will Long on 5/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VAbstractFilter.h"

@class VComment;

@interface VCommentFilter : VAbstractFilter

@property (nonatomic, retain) NSSet *comments;
@end

@interface VCommentFilter (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(VComment *)value;
- (void)removeCommentsObject:(VComment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

@end
