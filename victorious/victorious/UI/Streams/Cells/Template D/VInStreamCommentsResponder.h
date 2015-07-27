//
//  VInStreamCommentsResponder.h
//  victorious
//
//  Created by Sharif Ahmed on 7/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCommentMediaType.h"

@class VComment, VUser, VSequence;

/**
    Describes a set of methods that the in stream comments will call in response to various
        actions performed on the in stream comments cells.
 */
@protocol VInStreamCommentsResponder <NSObject>

/**
    Called when a comment is selected from the collection of in stream comments.
 
    @param comment The selected comment. May be nil.
    @param sequence The sequence that the comment was selected from. Will never be nil.
 */
- (void)actionForInStreamCommentSelection:(VComment *)comment fromSequence:(VSequence *)sequence;

/**
    Called when a hashtag is tapped from within an in stream comment.
 
    @param hashtag The hashtag selected from the in stream comment.
 */
- (void)actionForInStreamHashtagSelection:(NSString *)hashtag;

/**
    Called when a user is selected from an in stream comment.
 
    @param userId The remote id of the user selected from the in stream comment.
 */
- (void)actionForInStreamUserSelection:(NSNumber *)userId;

/**
    Called when a piece of media is selected from an in stream comment.
 
    @param mediaUrlString A string representing the url that the media should be loaded from.
    @param linkType The type of media represented by the media button in the in stream comment.
 */
- (void)actionForInStreamMediaSelection:(NSString *)mediaUrlString withMediaLinkType:(VCommentMediaType)linkType;

@end
