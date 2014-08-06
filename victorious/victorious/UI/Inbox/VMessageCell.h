//
//  VMessageCell.h
//  victorious
//
//  Created by Will Long on 5/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractCommentCell.h"

@class VCommentTextAndMediaView;

extern NSString * const kVMessageCellNibName;

@interface VMessageCell : UITableViewCell

@property (nonatomic, weak) IBOutlet VCommentTextAndMediaView *commentTextView;
@property (nonatomic, weak) IBOutlet UIButton                 *profileImageButton;
@property (nonatomic, weak) IBOutlet UILabel                  *timeLabel;

@property (nonatomic, readonly) UIColor *alernateChatBubbleTintColor; ///< The tint color used for the user's own messages

+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width text:(NSString *)text;

@end
