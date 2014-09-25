//
//  VRealTimeCommentsCell.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VRealTimeCommentsCell.h"

// Subviews
#import "VProgressBarView.h"

// Theme
#import "VThemeManager.h"

static const CGFloat kRealTimeCommentAvatarInset = 2.5f;

@interface VRealTimeCommentsCell ()

@property (weak, nonatomic) IBOutlet UIView *realtimeCommentStrip;
@property (weak, nonatomic) IBOutlet UIImageView *currentUserAvatar;
@property (weak, nonatomic) IBOutlet UILabel *currentUserNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeAgoLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentCommentBodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentAtTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *conversationClock;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet VProgressBarView *progressBar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingAlignmentRTCArrowToStipConstraint;

@end

@implementation VRealTimeCommentsCell

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), 92.0f);
}

+ (CGSize)desiredSizeForNoRealTimeCommentsWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), 5.0f);
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.currentUserAvatar.layer.cornerRadius = CGRectGetWidth(self.currentUserAvatar.bounds) * 0.5f;
    self.currentUserAvatar.layer.masksToBounds = YES;
    
    self.currentUserAvatar.image = nil;
    self.currentUserAvatar.hidden = YES;
    self.currentUserNameLabel.text = nil;
    self.currentCommentBodyLabel.text = nil;
    self.currentAtTimeLabel.text = nil;
    self.currentTimeAgoLabel.text = nil;
    self.conversationClock.hidden = YES;
    self.arrowImageView.alpha = 0.0f;
    
    self.currentUserNameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel1Font];
    self.currentCommentBodyLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    self.currentAtTimeLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel2Font];
    self.currentTimeAgoLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel2Font];
    self.arrowImageView.translatesAutoresizingMaskIntoConstraints = NO;
}

#pragma mark - Property Acceossors

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    self.progressBar.progressColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    [self.progressBar setProgress:progress
                         animated:YES];
}

#pragma mark - Public Methods

- (void)configureWithCurrentUserAvatarURL:(NSURL *)currentAvatarURL
                          currentUsername:(NSString *)username
                       currentTimeAgoText:(NSString *)timeAgoText
                       currentCommentBody:(NSString *)commentBody
                               atTimeText:(NSString *)atTimeText
               commentPercentThroughMedia:(CGFloat)percentThrough
{
    [self.currentUserAvatar setImageWithURL:currentAvatarURL
                           placeholderImage:[UIImage imageNamed:@"profile_thumb"]];
    self.currentUserNameLabel.text = username;
    self.currentTimeAgoLabel.text = timeAgoText;
    self.currentCommentBodyLabel.text = commentBody;
    self.currentAtTimeLabel.text = atTimeText;
    self.conversationClock.hidden = NO;
    self.arrowImageView.alpha = 1.0f;
    
    [UIView animateWithDuration:0.2f
                          delay:0.0f
         usingSpringWithDamping:0.7f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^
    {
        self.leadingAlignmentRTCArrowToStipConstraint.constant = CGRectGetWidth(self.realtimeCommentStrip.bounds)*percentThrough - (0.5 * CGRectGetWidth(self.arrowImageView.bounds));
        [self layoutIfNeeded];
    }
                     completion:nil];
}

- (void)addAvatarWithURL:(NSURL *)avatarURL
     withPercentLocation:(CGFloat)percentLocation
{
    UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                            0,
                                                                            CGRectGetHeight(self.realtimeCommentStrip.frame) - (2 * kRealTimeCommentAvatarInset),
                                                                            CGRectGetHeight(self.realtimeCommentStrip.frame) - (2 * kRealTimeCommentAvatarInset))];
    [avatarView setImageWithURL:avatarURL
               placeholderImage:[[UIImage imageNamed:@"profileGenericUser"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    avatarView.tintColor = [UIColor lightGrayColor];
    avatarView.center = CGPointMake(0 + (CGRectGetWidth(self.realtimeCommentStrip.bounds) * percentLocation),
                                    CGRectGetMidY(self.realtimeCommentStrip.bounds));
    avatarView.layer.cornerRadius = CGRectGetHeight(avatarView.bounds) * 0.5f;
    avatarView.layer.masksToBounds = YES;

    [self.realtimeCommentStrip addSubview:avatarView];
}

- (void)clearAvatarStrip
{
    NSMutableArray *subviewsOfSripExcludingProgressBar = [[NSMutableArray alloc] init];
    [self.realtimeCommentStrip.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (obj == self.progressBar)
        {
            return;
        }
        [subviewsOfSripExcludingProgressBar addObject:obj];
    }];
    [subviewsOfSripExcludingProgressBar makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end
