//
//  VCommentCell.h
//  victoriOS
//
//  Created by David Keegan on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VAbstractCommentCell.h"

@class VComment;
//@class VMessage;

static NSString *kCommentCellIdentifier = @"VCommentCell";
static NSString *kOtherCommentCellIdentifier = @"VOtherCommentCell";

extern CGFloat const kCommentCellYOffset;
extern CGFloat const kCommentMediaCellYOffset;
extern CGFloat const kCommentMinCellHeight;

@interface VCommentCell : VAbstractCommentCell

@property (strong, nonatomic) VComment* comment;

@end
