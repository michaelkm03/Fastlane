//
//  VConversationCell.m
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConversationCell.h"
#import "VThemeManager.h"
#import "NSDate+timeSince.h"

@interface VConversationCell()
@property (weak, nonatomic) IBOutlet UIView *seenView;
@end

@implementation VConversationCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.seenView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.conversation.seen"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.seenView.layer.cornerRadius = CGRectGetHeight(self.seenView.bounds)/2;
}

- (void)setSeen:(BOOL)seen
{
    [self.seenView setHidden:seen];
}

- (void)setConversation:(VConversation *)conversation
{
    self.usernameLabel.text  =   @"Some User";   //self.conversation.XXXXXX;
    self.messageLabel.text = @"A Messages";  //self.conversation.XXXXX;
    NSDate* date    =   [NSDate date];
    self.dateLabel.text = [date timeSince];
}

@end
