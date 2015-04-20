//
//  VUserProfileHeaderViewController.h
//  victorious
//
//  Created by Will Long on 6/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"
#import "VUserProfileHeader.h"

@class VUser, VDefaultProfileImageView, VDependencyManager;

@interface VUserProfileHeaderViewController : UIViewController <VUserProfileHeader, VHasManagedDependencies>

@property (nonatomic, strong, readonly) VDependencyManager *dependencyManager;
@property (nonatomic, assign, readonly) BOOL isCurrentUser;

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIButton *primaryActionButton;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UILabel *taglineLabel;
@property (nonatomic, weak) IBOutlet UILabel *followersLabel;
@property (nonatomic, weak) IBOutlet UILabel *followersHeader;
@property (nonatomic, weak) IBOutlet UIButton *followersButton;
@property (nonatomic, weak) IBOutlet UILabel *followingLabel;
@property (nonatomic, weak) IBOutlet UILabel *followingHeader;
@property (nonatomic, weak) IBOutlet UIButton *followingButton;
@property (nonatomic, weak) IBOutlet UIView *userStatsBar;
@property (nonatomic, weak) IBOutlet VDefaultProfileImageView *profileImageView;

@end
