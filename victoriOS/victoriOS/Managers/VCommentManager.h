//
//  VCommentManager.h
//  victoriOS
//
//  Created by Will Long on 12/3/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sequence+RestKit.h"

@interface VCommentManager : NSObject

+ (void)addCommentText:(NSString*)text
         commentData:(NSData*)media
       mediaExtension:(NSString*)extension
           toSequence:(Sequence*)sequence
            andParent:(Comment*)parent;

+ (void)removeComment:(Comment*)comment withReason:(NSString*)removalReason;

+ (void)shareToFacebook:(Comment*)comment;
+ (void)shareToTwitter:(Comment*)comment;

+ (void)flagComment:(Comment*)comment;

+ (void)likeComment:(Comment*)comment;
+ (void)dislikeComment:(Comment*)comment;
+ (void)unvoteComment:(Comment*)comment;

+ (void) testCommentSystem:(Comment*)comment;

@end
