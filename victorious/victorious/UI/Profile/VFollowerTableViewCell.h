//
//  VFollowerTableViewCell.h
//  victorious
//
//  Created by Gary Philipp on 5/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSharedCollectionReusableViewMethods.h"
#import "VHasManagedDependencies.h"

@class VUser, VDependencyManager;

/**
 *  A VFollowerTableViewCell presents UI for previewing a user's avatar, name, 
 *  location, and the current follow state.
 *
 *  VFollowerTableViewCell will send commands up the responder chain by looking 
 *  for responders that implement the VFollowCommand protocol.
 */
@interface VFollowerTableViewCell : UITableViewCell <VSharedCollectionReusableViewMethods, VHasManagedDependencies>

/**
 *  The user that this follower cell represents. This cell will KVO the following 
 *  status on this user.
 */
@property (nonatomic, strong) VUser *profile;

@end
