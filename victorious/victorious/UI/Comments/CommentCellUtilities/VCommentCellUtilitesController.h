//
//  VCommentCellUtilitesController.h
//  victorious
//
//  Created by Patrick Lynch on 12/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSwipeViewController.h"
#import "VComment.h"
#import "VCommentCellUtilitiesDelegate.h"

/**
 An object that handles edit, delete and flag functionalities for comments.
 Edit is a slightly different case in that presenting another view controller
 is necessary to allow the user to input new text, so the request to edit
 will be forwarded to calling code through VCommentCellUtilitiesDelegate.
 */
@interface VCommentCellUtilitesController : NSObject <VSwipeViewCellDelegate>

- (instancetype)initWithComment:(VComment *)comment
                       cellView:(UIView *)cellView
                       delegate:(id<VCommentCellUtilitiesDelegate>)delegate;

@end
