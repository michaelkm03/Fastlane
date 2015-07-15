//
//  VInStreamCommentsCell.h
//  victorious
//
//  Created by Sharif Ahmed on 7/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@class VInStreamCommentCellContents, VTagSensitiveTextView, VDefaultProfileButton;

@interface VInStreamCommentsCell : VBaseCollectionViewCell

- (void)setupWithInStreamCommentCellContents:(VInStreamCommentCellContents *)contents;

+ (VInStreamCommentsCell *)sizingCell;

+ (CGFloat)desiredHeightForCommentCellContents:(VInStreamCommentCellContents *)contents withMaxWidth:(CGFloat)width;

@end
