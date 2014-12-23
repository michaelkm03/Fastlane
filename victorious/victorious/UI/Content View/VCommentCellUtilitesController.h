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

@interface VCommentCellUtilitesController : NSObject <VSwipeViewCellDelegate>

- (instancetype)initWithComment:(VComment *)comment
                       cellView:(UIView *)cellView
                       delegate:(id<VCommentCellUtilitiesDelegate>)delegate;

@end
