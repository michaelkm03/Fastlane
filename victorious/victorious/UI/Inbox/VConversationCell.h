//
//  VConversationCell.h
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTableViewCell.h"
@class VConversation;

@interface VConversationCell : VTableViewCell
@property (nonatomic, readwrite, strong)    VConversation*  conversation;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic) BOOL seen;
@end
