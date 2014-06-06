//
//  VConversationCell.h
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTableViewCell.h"

extern CGFloat const kVConversationCellHeight;

@class VConversation;

@interface VConversationCell : VTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;
@property (strong, nonatomic) VConversation* conversation;
@property (nonatomic) BOOL seen;

@end
