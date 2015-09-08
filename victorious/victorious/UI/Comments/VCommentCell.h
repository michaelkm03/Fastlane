//
//  VCommentCell.h
//  victoriOS
//
//  Created by David Keegan on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VSwipeTableViewCell.h"

#import "VFocusable.h"

@class VCommentTextAndMediaView, VDefaultProfileImageView;

extern NSString * const kVCommentCellNibName;

@interface VCommentCell : VSwipeTableViewCell <VFocusable>

@property (nonatomic, weak, readwrite) IBOutlet UILabel                   *usernameLabel;
@property (nonatomic, weak, readonly)  IBOutlet VCommentTextAndMediaView  *textAndMediaView;
@property (nonatomic, weak, readonly)  IBOutlet UILabel                   *timeLabel;
@property (nonatomic, weak, readonly)  IBOutlet VDefaultProfileImageView  *profileImageView;
@property (nonatomic, copy)                     void                     (^onProfileImageTapped)();

+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width comment:(VComment *)comment;

@end
