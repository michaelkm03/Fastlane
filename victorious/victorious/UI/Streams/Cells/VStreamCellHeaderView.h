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

@class VSequence, VDefaultProfileButton;

@interface VStreamCellHeaderView : UIView

@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *parentLabel;
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

- (void)hideCommentsButton;

@end
