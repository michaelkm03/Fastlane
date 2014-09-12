//
//  VUserInfoStreamView.m
//  victorious
//
//  Created by Lawrence Leach on 9/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCellHeaderView.h"
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


static VLargeNumberFormatter* largeNumberFormatter;

@implementation VStreamCellHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
    if (!largeNumberFormatter)
    {
        largeNumberFormatter = [[VLargeNumberFormatter alloc] init];
    }
    
    self.commentViews = [[NSMutableArray alloc] init];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.profileImageButton.layer.cornerRadius = CGRectGetHeight(self.profileImageButton.bounds)/2;
    self.profileImageButton.clipsToBounds = YES;
}

- (void)hideCommentsButton
{
    [self.commentButton setHidden:YES];
    [self.commentHitboxButton setHidden:YES];
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    self.usernameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel1Font];
    self.parentLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
    self.dateLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
    self.dateImageView.image = [self.dateImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.commentButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [self.commentButton.titleLabel setFont:[[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font]];
    

    [self.profileImageButton setImageWithURL:[NSURL URLWithString:self.sequence.user.profileImagePathSmall ?: self.sequence.user.pictureUrl]
                            placeholderImage:[UIImage imageNamed:@"profile_thumb"]
                                    forState:UIControlStateNormal];

    self.dateLabel.text = [self.sequence.releasedAt timeSince];

    NSString* commentCount = self.sequence.commentCount.integerValue ? [largeNumberFormatter stringForInteger:self.sequence.commentCount.integerValue] : @"";
    [self.commentButton setTitle:commentCount forState:UIControlStateNormal];
    
    
    NSString* parentUserString;
    if ([self.sequence isRepost] && self.sequence.parentUser)
    {
        parentUserString = [NSString stringWithFormat:NSLocalizedString(@"repostedFromFormat", nil), self.sequence.parentUser.name];
    }
    
    if ([self.sequence isRemix] && self.sequence.parentUser)
    {
        parentUserString = [NSString stringWithFormat:NSLocalizedString(@"remixedFromFormat", nil), self.sequence.parentUser.name];
    }
    
    self.parentLabel.text = parentUserString;
    
    self.usernameLabel.text = self.sequence.user.name;
    self.dateLabel.text = [self.sequence.releasedAt timeSince];
    
    if (!self.sequence.parentUser)
    {
        self.userInfoViewHeightConstraint.constant = self.usernameLabel.intrinsicContentSize.height;
    }

}



@end
