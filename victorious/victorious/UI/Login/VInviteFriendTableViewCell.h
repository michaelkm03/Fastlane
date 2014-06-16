//
//  VInviteFriendTableViewCell.h
//  victorious
//
//  Created by Gary Philipp on 6/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VUser;
@class VInviteFriendTableViewCell;

#import "VTableViewCell.h"

@protocol VInviteFriendTableViewCellDelegate <NSObject>
@required
-(void)cellDidSelectInvite:(VInviteFriendTableViewCell *)cell;
-(void)cellDidSelectUninvite:(VInviteFriendTableViewCell *)cell;
@end

@interface VInviteFriendTableViewCell : VTableViewCell
@property (nonatomic, strong)   VUser*  profile;

@property (nonatomic)           BOOL    shouldInvite;

@property (nonatomic, weak)     id <VInviteFriendTableViewCellDelegate> delegate;
@end
