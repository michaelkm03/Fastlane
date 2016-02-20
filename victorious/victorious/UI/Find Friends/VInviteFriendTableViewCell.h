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
@property (nonatomic, readonly) BOOL haveRelationship;
@property (nonatomic, weak) IBOutlet VFollowControl *followUserControl;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong, readwrite) NSString *sourceScreenName;

- (void)updateFollowStatusAnimated:(BOOL)animated;
- (IBAction)followUnfollowUser:(VFollowControl *)sender;

@end
