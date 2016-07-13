//
//  VAbstractUserProfileHeaderViewController.h
//  victorious
//
//  Created by Patrick Lynch on 4/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"
#import "VUserProfileHeader.h"
#import "VButton.h"

@class VUser, VDependencyManager;

@interface VAbstractUserProfileHeaderViewController : UIViewController <VUserProfileHeader, VHasManagedDependencies>

@property (nonatomic, strong, readonly) VDependencyManager *dependencyManager;
@property (nonatomic, strong, readonly) UIImageView *profileImageView;
@property (nonatomic, assign, readonly) BOOL isCurrentUser;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet VButton *primaryActionButton;
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
@property (nonatomic, weak) IBOutlet UIView *userStatsBarBackgroundContainer;

- (void)applyStyle;

@end
