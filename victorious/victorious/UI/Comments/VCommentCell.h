//
//  VCommentCell.h
//  victoriOS
//
//  Created by David Keegan on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VSwipeTableViewCell.h"

@class VCommentTextAndMediaView, VDefaultProfileImageView;

extern NSString * const kVCommentCellNibName;

@interface VCommentCell : VSwipeTableViewCell

@property (nonatomic, weak, readwrite) IBOutlet UILabel                   *usernameLabel;
@property (nonatomic, weak, readonly)  IBOutlet VCommentTextAndMediaView  *commentTextView;
@property (nonatomic, weak, readonly)  IBOutlet UILabel                   *timeLabel;
@property (nonatomic, weak, readonly)  IBOutlet VDefaultProfileImageView  *profileImageView;
@property (nonatomic, copy)                     void                     (^onProfileImageTapped)();

+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width text:(NSString *)text withMedia:(BOOL)hasMedia;

@end
