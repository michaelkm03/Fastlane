//
//  VCommentCell.h
//  victoriOS
//
//  Created by David Keegan on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VTableViewCell.h"

@class VComment;
@class VMessage;

static NSString *kCommentCellIdentifier = @"VCommentCell";
static NSString *kOtherCommentCellIdentifier = @"VOtherCommentCell";

@interface VCommentCell : VTableViewCell

@property (strong, nonatomic) id commentOrMessage;

@end
