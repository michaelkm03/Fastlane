//
//  VCommentCell.m
//  victoriOS
//
//  Created by David Keegan on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VCommentCell.h"
#import "VCommentTextAndMediaView.h"
#import "VThemeManager.h"
#import "UIImage+ImageCreation.h"
#import "VDefaultProfileImageView.h"
#import "UIView+Autolayout.h"

NSString * const kVCommentCellNibName = @"VCommentCell";

static const CGFloat      kMinimumCellHeight = 45.0f;
static const UIEdgeInsets kTextInsets        = { 39.0f, 66.0f, 11.0f, 25.0f };

@interface VCommentCell()

@property (nonatomic, weak, readwrite) IBOutlet VCommentTextAndMediaView *commentTextView;
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
    
    [self setupSwipeView];
    [self.contentView v_addFitToParentConstraintsToSubview:self.swipeViewController.view];
}

+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width text:(NSString *)text withMedia:(BOOL)hasMedia
{
    return MAX([VCommentTextAndMediaView estimatedHeightWithWidth:(width - kTextInsets.left - kTextInsets.right) text:text withMedia:hasMedia] +
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
    [self.commentTextView resetView];
    [self.profileImageView setup];
}

@end
