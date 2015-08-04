//
//  VCommentCell.m
//  victoriOS
//
//  Created by David Keegan on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VCommentCell.h"
#import "VThemeManager.h"
#import "UIImage+ImageCreation.h"
#import "VDefaultProfileImageView.h"
#import "UIView+Autolayout.h"
#import "VCommentTextAndMediaView.h"

NSString * const kVCommentCellNibName = @"VCommentCell";

static const CGFloat      kMinimumCellHeight = 45.0f;
static const UIEdgeInsets kTextInsets        = { 39.0f, 66.0f, 11.0f, 55.0f };

@interface VCommentCell()

@property (nonatomic, weak, readwrite) IBOutlet VCommentTextAndMediaView *textAndMediaView;
@property (nonatomic, weak, readwrite) IBOutlet UILabel                  *timeLabel;
@property (nonatomic, weak, readwrite) IBOutlet VDefaultProfileImageView *profileImageView;
@property (nonatomic, weak, readwrite) IBOutlet UIButton                 *profileImageButton;

@end

@implementation VCommentCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.timeLabel.font = [UIFont fontWithName:@"MuseoSans-100" size:11.0f];
    self.usernameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.profileImageView.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    
    [self setupSwipeView];
    [self.contentView v_addFitToParentConstraintsToSubview:self.swipeViewController.view];
}

+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width comment:(VComment *)comment
{
    return MAX([VCommentTextAndMediaView estimatedHeightWithWidth:(width - kTextInsets.left - kTextInsets.right) comment:comment] +
               kTextInsets.top +
               kTextInsets.bottom,
               kMinimumCellHeight);
}

- (IBAction)profileImageTapped:(UIButton *)sender
{
    if (self.onProfileImageTapped)
    {
        self.onProfileImageTapped();
    }
}

- (void)prepareForReuse
{
    [self.textAndMediaView resetView];
    [self.profileImageView setup];
}

#pragma mark - Focus

- (void)setHasFocus:(BOOL)hasFocus
{
    self.textAndMediaView.inFocus = hasFocus;
}

- (CGRect)contentArea
{
    CGRect mediaThumbnailFrame = self.textAndMediaView.mediaAttachmentView.frame;
    CGRect mediaFrame = CGRectMake(CGRectGetMinX(mediaThumbnailFrame),
                                   CGRectGetMinY(self.textAndMediaView.frame) + CGRectGetMinY(mediaThumbnailFrame),
                                   CGRectGetWidth(mediaThumbnailFrame),
                                   CGRectGetHeight(mediaThumbnailFrame));
    return mediaFrame;
}

@end
