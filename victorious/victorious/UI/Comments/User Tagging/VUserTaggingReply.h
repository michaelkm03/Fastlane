//
//  VUserTaggingReply.h
//  victorious
//
//  Created by Steven F Petteruti on 7/31/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VUser;

@protocol VUserTaggingReply <NSObject>

/*
 *  Text storage should adhere to this protocol. It is called
 *  when a user swipes to replly on a comment.
 */
- (void)repliedToUser:(VUser *)user;

@end
