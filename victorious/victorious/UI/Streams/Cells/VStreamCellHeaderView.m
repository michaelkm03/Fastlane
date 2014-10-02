//
//  VStreamCellHeaderView.m
//  victorious
//
//  Created by Lawrence Leach on 9/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCellHeaderView.h"
#import "VStreamViewCell.h"
#import "VDefaultProfileButton.h"

#import "VSequence.h"
#import "VObjectManager+Sequence.h"
#import "VThemeManager.h"
#import "NSDate+timeSince.h"
#import "VUser.h"
#import "VHashTags.h"
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"
#import "VLargeNumberFormatter.h"
#import "UIImage+ImageCreation.h"
#import "UIButton+VImageLoading.h"
#import "VConstants.h"

#import "VUserProfileViewController.h"


static VLargeNumberFormatter *largeNumberFormatter;

static const CGFloat kUserInfoViewMaxHeight = 25.0f;

@implementation VStreamCellHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
    {
        largeNumberFormatter = [[VLargeNumberFormatter alloc] init];
    });
    
    _commentViews = [[NSMutableArray alloc] init];
    _isFromProfile = NO;
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    self.profileImageButton.layer.cornerRadius = CGRectGetHeight(self.profileImageButton.bounds)/2;
//    self.profileImageButton.clipsToBounds = YES;
//}

- (void)hideCommentsButton
{
    [self.commentButton setHidden:YES];
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    // Style the ui
    self.usernameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel1Font];
    self.parentLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
    self.dateLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
    self.dateImageView.image = [self.dateImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.commentButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [self.commentButton.titleLabel setFont:[[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font]];
    
    self.profileImageButton.user = self.sequence.user;
    
    self.dateLabel.text = [self.sequence.releasedAt timeSince];

    // Get comment count (if any)
    NSString *commentCount = self.sequence.commentCount.integerValue ? [largeNumberFormatter stringForInteger:self.sequence.commentCount.integerValue] : @"";
    [self.commentButton setTitle:commentCount forState:UIControlStateNormal];
    
    // Format repost / remix string
    NSString *parentUserString;
    if ([self.sequence isRepost] && self.sequence.parentUser)
    {
        parentUserString = [NSString stringWithFormat:NSLocalizedString(@"repostedFromFormat", nil), self.sequence.parentUser.name];
    }
    
    if ([self.sequence isRemix] && self.sequence.parentUser)
    {
        parentUserString = [NSString stringWithFormat:NSLocalizedString(@"remixedFromFormat", nil), self.sequence.parentUser.name];
    }
    
    self.parentLabel.text = parentUserString;
    
    // Set username and format date
    self.usernameLabel.text = self.sequence.user.name;
    self.dateLabel.text = [self.sequence.releasedAt timeSince];
    
    
    // Check if this is a repost / remix and size the userInfoView accordingly
    if (self.sequence.parentUser)
    {
        self.userInfoViewHeightConstraint.constant = kUserInfoViewMaxHeight;
    }
    else
    {
        self.userInfoViewHeightConstraint.constant = self.usernameLabel.intrinsicContentSize.height;
    }

}

#pragma mark - Button Actions

- (IBAction)profileButtonAction:(id)sender
{
    
    //If this cell is from the profile we should disable going to the profile
    if (self.isFromProfile)
    {
        return;
    }
    
    VUserProfileViewController *profileViewController = [VUserProfileViewController userProfileWithUser:self.sequence.user];
    [self.parentViewController.navigationController pushViewController:profileViewController animated:YES];
    
}

@end
