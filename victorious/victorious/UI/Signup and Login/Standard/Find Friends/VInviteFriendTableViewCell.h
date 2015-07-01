//
//  VInviteFriendTableViewCell.h
//  victorious
//
//  Created by Gary Philipp on 6/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSharedCollectionReusableViewMethods.h"

@class VUser, VFollowControl, VDependencyManager;

@interface VInviteFriendTableViewCell : UITableViewCell <VSharedCollectionReusableViewMethods>

@property (nonatomic, strong) VUser *profile;
@property (nonatomic, copy) void (^followAction)(void);
@property (nonatomic, readonly) BOOL haveRelationship;
@property (nonatomic, weak) IBOutlet VFollowControl *followUserControl;
@property (nonatomic, assign) BOOL shouldAnimateFollowing;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

- (void)updateFollowStatus;

@end
