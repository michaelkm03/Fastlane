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

NS_ASSUME_NONNULL_BEGIN

@protocol VCommentCellUtilitiesDelegate <NSObject>

/**
 Editing a comment has been requested, but requires calling code to display
 additional UI to allow the user to edit the comment's text.
 */
- (void)editComment:(VComment *)comment;

/**
 Used for replying to a comment, and requires the calling code to update
 the UI.
 */
- (void)replyToComment:(VComment *)comment;

/**
 Alerts regarding comment updates will be presented on the controller
 returned from this method.
 */
- (UIViewController *)viewControllerForAlerts;

@end

NS_ASSUME_NONNULL_END
