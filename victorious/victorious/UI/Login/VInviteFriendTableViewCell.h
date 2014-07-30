//
//  VInviteFriendTableViewCell.h
//  victorious
//
//  Created by Gary Philipp on 6/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

static NSString * const kFollowCellReuseID = @"followerCell";

@class VUser;

@interface VInviteFriendTableViewCell : UITableViewCell
@property (nonatomic, strong)   VUser*  profile;

@end
