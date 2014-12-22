//
//  VEditCommentsController.h
//  victorious
//
//  Created by Patrick Lynch on 12/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSwipeViewController.h"
#import "VComment.h"

@interface VEditCommentsController : NSObject <VSwipeViewCellDelegate>

- (instancetype)initWithComment:(VComment *)comment cellView:(UIView *)cellView;

@end
