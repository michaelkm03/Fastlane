//
//  VInviteFriendTableViewCell.h
//  victorious
//
//  Created by Gary Philipp on 6/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

extern NSString * const VInviteFriendTableViewCellNibName;

@class VUser, VFollowUserControl;

@interface VInviteFriendTableViewCell : UITableViewCell

@property (nonatomic, strong) VUser *profile;
@property (nonatomic, copy) void (^followAction)(void);
@property (nonatomic, readonly) BOOL haveRelationship;
@property (nonatomic, weak) IBOutlet VFollowUserControl *followUserControl;

- (void)updateFollowStatus;

@end
