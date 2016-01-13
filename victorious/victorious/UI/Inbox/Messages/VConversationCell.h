//
//  VConversationCell.h
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTableViewCell.h"
#import "VCellWithProfileDelegate.h"

extern const CGFloat VConversationCellHeight;

@class VConversation, VDefaultProfileButton, VDependencyManager;

@interface VConversationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet VDefaultProfileButton *profileButton;
@property (strong, nonatomic) VConversation *conversation;
@property (weak, nonatomic) UITableViewController *parentTableViewController;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

+ (NSString *)suggestedReuseIdentifier;

@property (nonatomic, strong) id<VCellWithProfileDelegate> delegate;

@end
