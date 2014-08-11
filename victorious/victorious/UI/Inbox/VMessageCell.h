//
//  VMessageCell.h
//  victorious
//
//  Created by Will Long on 5/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VCommentTextAndMediaView;

extern NSString * const kVMessageCellNibName;

@interface VMessageCell : UITableViewCell

@property (nonatomic, weak, readonly) IBOutlet VCommentTextAndMediaView  *commentTextView;
@property (nonatomic, weak, readonly) IBOutlet UILabel                   *timeLabel;
@property (nonatomic, weak, readonly) IBOutlet UIImageView               *profileImageView;
@property (nonatomic, copy)                    void                     (^onProfileImageTapped)();

@property (nonatomic, readonly) UIColor *alernateChatBubbleTintColor; ///< The tint color used for the user's own messages

+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width text:(NSString *)text withMedia:(BOOL)hasMedia;

@end
