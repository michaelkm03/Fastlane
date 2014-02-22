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

extern CGFloat const kCommentCellWidth;
extern CGFloat const kCommentCellYOffset;
extern CGFloat const kMediaCommentCellYOffset;
extern CGFloat const kMinCellHeight;

@interface VCommentCell : VTableViewCell

@property (strong, nonatomic) id commentOrMessage;

+ (CGSize)frameSizeForMessageText:(NSString*)text;

@end
