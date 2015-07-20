//
//  VInStreamCommentsResponder.h
//  victorious
//
//  Created by Sharif Ahmed on 7/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VMediaType.h"

@class VComment, VUser, VSequence;

@protocol VInStreamCommentsResponder <NSObject>

- (void)actionForInStreamCommentSelection:(VComment *)comment fromSequence:(VSequence *)sequence;

- (void)actionForInStreamHashtagSelection:(NSString *)string;

- (void)actionForInStreamUserSelection:(NSNumber *)userId;

- (void)actionForInStreamMediaSelection:(NSString *)mediaUrlString withMediaLinkType:(VMediaType)linkType;

@end
