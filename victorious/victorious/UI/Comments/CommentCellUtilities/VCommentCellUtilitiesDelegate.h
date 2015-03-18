//
//  VCommentCellUtilitiesDelegate.h
//  victorious
//
//  Created by Patrick Lynch on 12/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VUserTaggingTextStorageDelegate.h"

@class VComment;

@protocol VCommentCellUtilitiesDelegate <NSObject>

/**
 The comment has been removed from the database on the backend and
 calling code should now update the UI.
 */
- (void)commentRemoved:(VComment *)comment;

/**
 Editing a comment has been requested, but requires calling code to display
 additional UI to allow the user to edit the comment's text.
 */
- (void)editComment:(VComment *)comment;

@end