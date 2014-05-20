//
//  VMessageCell.h
//  victorious
//
//  Created by Will Long on 5/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractCommentCell.h"

@class VMessage;

static NSString *kMessageCellIdentifier = @"VMessageCell";
static NSString *kOtherMessageCellIdentifier = @"VOtherMessageCell";

extern CGFloat const kMessageCellYOffset;
extern CGFloat const kMessageMediaCellYOffset;
extern CGFloat const kMessageMinCellHeight;

@interface VMessageCell : VAbstractCommentCell

@property (strong, nonatomic) VMessage* message;

@end
