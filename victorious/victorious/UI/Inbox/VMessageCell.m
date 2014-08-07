//
//  VMessageCell.m
//  victorious
//
//  Created by Will Long on 5/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCommentTextAndMediaView.h"
#import "VMessageCell.h"

NSString * const kVMessageCellNibName = @"VMessageCell";

static const CGFloat      kMinimumCellHeight = 71.0f;
static const UIEdgeInsets kTextInsets        = { 24.0f, 74.0f, 24.0f, 32.0f };

@interface VMessageCell ()

@property (nonatomic, weak) IBOutlet UIImageView *chatBubble;

@end

@implementation VMessageCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.chatBubble.image = [[[UIImage imageNamed:@"ChatBubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 4.0f) resizingMode:UIImageResizingModeTile] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.timeLabel.font = [UIFont fontWithName:@"MuseoSans-100" size:11.125f];
}

+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width text:(NSString *)text withMedia:(BOOL)hasMedia
{
    return MAX([VCommentTextAndMediaView estimatedHeightWithWidth:(width - kTextInsets.left - kTextInsets.right) text:text withMedia:hasMedia] +
                kTextInsets.top +
                kTextInsets.bottom,
               kMinimumCellHeight);
}

- (UIColor *)alernateChatBubbleTintColor
{
    return [UIColor colorWithRed:0.914f green:0.914f blue:0.914f alpha:1.0f];
}

- (void)prepareForReuse
{
    self.chatBubble.tintColor = [UIColor whiteColor];
    [self.commentTextView resetView];
}

@end
