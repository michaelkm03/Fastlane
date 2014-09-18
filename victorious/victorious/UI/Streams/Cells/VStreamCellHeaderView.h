//
//  VStreamCellHeaderView.h
//  victorious
//
//  Created by Lawrence Leach on 9/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VSequence;

@interface VStreamCellHeaderView : UIView

@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *parentLabel;
@property (nonatomic, weak) IBOutlet UIImageView *dateImageView;
@property (nonatomic, weak) IBOutlet UIView *userInfoView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *userInfoViewHeightConstraint;
@property (nonatomic, weak) IBOutlet UIButton *profileImageButton;
@property (nonatomic, weak) IBOutlet UIButton *profileHitboxutton;
@property (nonatomic, weak) IBOutlet UIButton *commentButton;
@property (nonatomic, weak) IBOutlet UIButton *commentHitboxButton;

@property (nonatomic, strong) UIViewController *parentViewController;
@property (nonatomic) BOOL isFromProfile;

@property (nonatomic, weak) VSequence *sequence;
@property (nonatomic, strong) NSMutableArray *commentViews;

- (void)hideCommentsButton;

@end
