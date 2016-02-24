//
//  VStreamCollectionViewController+VInStreamCommentsResponder.m
//  victorious
//
//  Created by Sharif Ahmed on 7/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCollectionViewController+VInStreamCommentsResponder.h"

@implementation VStreamCollectionViewController (VInStreamCommentsResponder)

- (void)actionForInStreamCommentSelection:(VComment *)comment fromSequence:(VSequence *)sequence
{
    [self.sequenceActionController showCommentsWithSequence:sequence withSelectedComment:comment];
}

- (void)actionForInStreamHashtagSelection:(NSString *)hashtag
{
    [self showHashtagStreamWithHashtag:hashtag];
}

- (void)actionForInStreamUserSelection:(NSNumber *)userId
{
    [self.sequenceActionController showProfileWithRemoteId:userId];
}

- (void)actionForInStreamMediaSelection:(NSURL *)mediaUrl withMediaLinkType:(VCommentMediaType)linkType
{
    [self.sequenceActionController showMediaContentViewForUrl:mediaUrl withMediaLinkType:linkType];
}

@end
