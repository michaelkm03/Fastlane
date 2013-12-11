//
//  VCommentManager.h
//  victoriOS
//
//  Created by Will Long on 12/3/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSequence+RestKit.h"

@interface VCommentManager : NSObject

+ (void)addCommentText:(NSString*)text
         commentData:(NSData*)media
       mediaExtension:(NSString*)extension
           toSequence:(VSequence*)sequence
            andParent:(VComment*)parent;

+ (void)removeComment:(VComment*)comment withReason:(NSString*)removalReason;

+ (void)flagComment:(VComment*)comment;

+ (void)likeComment:(VComment*)comment;
+ (void)dislikeComment:(VComment*)comment;
+ (void)unvoteComment:(VComment*)comment;

+ (void) testCommentSystem:(VComment*)comment;

@end
