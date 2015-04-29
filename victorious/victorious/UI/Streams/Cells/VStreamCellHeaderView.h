//
//  VStreamCellHeaderView.h
//  victorious
//
//  Created by Lawrence Leach on 9/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VSequenceActionsDelegate.h"
#import "VStreamCollectionCell.h"
#import "VPassthroughContainerView.h"

@class VSequence, VDefaultProfileButton, VDependencyManager;

@interface VStreamCellHeaderView : VPassthroughContainerView

@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *dateImageView;
@property (nonatomic, weak) IBOutlet UIView *userInfoView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *userInfoViewHeightConstraint;
@property (nonatomic, weak) IBOutlet VDefaultProfileButton *profileImageButton;
@property (nonatomic, weak) IBOutlet UIButton *profileHitboxutton;
@property (nonatomic, weak) IBOutlet UIButton *commentButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *usernameLabelBottomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *usernameLabelTopConstraint;

@property (nonatomic, weak) id<VSequenceActionsDelegate> delegate;

@property (nonatomic, strong) UIViewController *parentViewController;

@property (nonatomic, weak) VSequence *sequence;
@property (nonatomic, strong) NSMutableArray *commentViews;

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) UIColor *colorForParentSequenceAuthorName; ///< applied to the "remix from..." username (only the username portion)
@property (nonatomic, strong) UIColor *colorForParentSequenceText; ///< applied to the "remix from..." portion of the subtitle (only the "remix from" or "repost from" portion)

- (void)hideCommentsButton;
- (void)reloadCommentsCount;
- (void)refreshAppearanceAttributes;
- (void)refreshParentLabelAttributes;

@end
