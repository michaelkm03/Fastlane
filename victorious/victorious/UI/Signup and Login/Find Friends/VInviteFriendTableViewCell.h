//
//  VInviteFriendTableViewCell.h
//  victorious
//
//  Created by Gary Philipp on 6/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

extern NSString * const VInviteFriendTableViewCellNibName;

@class VUser;

@interface VInviteFriendTableViewCell : UITableViewCell

@property (nonatomic, strong) VUser *profile;
@property (nonatomic, copy) void (^followAction)(void);
@property (nonatomic) BOOL haveRelationship;

@property (nonatomic, weak) IBOutlet UIImageView *followIconImageView;

- (void)imageTapAction:(id)sender;
- (void)disableFollowIcon:(id)sender;
- (void)flipFollowIconAction:(id)sender;

@end
