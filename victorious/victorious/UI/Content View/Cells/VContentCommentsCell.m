//
//  VContentCommentsCell.m
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentCommentsCell.h"

// Subviews
#import "VCommentTextAndMediaView.h"

static const UIEdgeInsets kTextInsets        = { 36.0f, 56.0f, 11.0f, 25.0f };

@interface VContentCommentsCell ()

@property (weak, nonatomic) IBOutlet UIImageView *commentersAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *commentersUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *realtimeCommentLocationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *seperatorImageView;
@property (weak, nonatomic) IBOutlet VCommentTextAndMediaView *commentAndMediaView;

@end

@implementation VContentCommentsCell

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), 70.0f);
}

+ (CGSize)sizeWithFullWidth:(CGFloat)width
                commentBody:(NSString *)commentBody
                andHasMedia:(BOOL)hasMedia
{
    CGFloat textHeight = [VCommentTextAndMediaView estimatedHeightWithWidth:(width - kTextInsets.left - kTextInsets.right)
                                                                   text:commentBody
                                                              withMedia:hasMedia];
    CGFloat finalHeight = textHeight + kTextInsets.top + kTextInsets.bottom;
    return CGSizeMake(width, finalHeight);
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.seperatorImageView.image = [self.seperatorImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.seperatorImageView.tintColor = [UIColor colorWithRed:229/255.0f green:229/255.0f blue:229/255.0f alpha:1.0f];
    
    self.commentersAvatarImageView.layer.cornerRadius = CGRectGetWidth(self.commentersAvatarImageView.bounds) * 0.5f;
    self.commentersAvatarImageView.layer.cornerRadius = CGRectGetHeight(self.commentersAvatarImageView.bounds) * 0.5f;
    self.commentersAvatarImageView.layer.masksToBounds = YES;
    self.commentersAvatarImageView.image = [self.commentersAvatarImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.commentersAvatarImageView.tintColor = [UIColor lightGrayColor];
    
    self.commentAndMediaView.preferredMaxLayoutWidth = CGRectGetWidth(self.commentAndMediaView.frame);

    [self prepareContentAndMediaView];
}

- (void)prepareContentAndMediaView
{
    [self.commentAndMediaView resetView];
    self.commentAndMediaView.hasMedia = NO;
    self.commentAndMediaView.mediaThumbnailView.hidden = YES;
}

#pragma mark - UICollectionReusableView

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self prepareContentAndMediaView];
}

#pragma mark - Property Accessor

- (void)setHasMedia:(BOOL)hasMedia
{
    _hasMedia = hasMedia;
    self.commentAndMediaView.mediaThumbnailView.hidden = !hasMedia;
}

- (void)setMediaPreviewURL:(NSURL *)mediaPreviewURL
{
    _mediaPreviewURL = [mediaPreviewURL copy];
    [self.commentAndMediaView.mediaThumbnailView setImageWithURL:mediaPreviewURL];
}

- (void)setMediaIsVideo:(BOOL)mediaIsVideo
{
    _mediaIsVideo = mediaIsVideo;
    self.commentAndMediaView.playIcon.hidden = !mediaIsVideo;
}

- (void)setCommentBody:(NSString *)commentBody
{
    _commentBody = [commentBody  copy];
    self.commentAndMediaView.text = commentBody;
}

- (void)setCommenterName:(NSString *)commenterName
{
    _commenterName = [commenterName copy];
    self.commentersUsernameLabel.text = commenterName;
}

- (void)setURLForCommenterAvatar:(NSURL *)URLForCommenterAvatar
{
    _URLForCommenterAvatar = [URLForCommenterAvatar copy];
    [self.commentersAvatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:URLForCommenterAvatar]
                                          placeholderImage:nil
                                                   success:nil
                                                   failure:nil];
}

- (void)setTimestampText:(NSString *)timestampText
{
    _timestampText = [timestampText copy];
    self.timestampLabel.text = timestampText;
}

- (void)setRealTimeCommentText:(NSString *)realTimeCommentText
{
    _realTimeCommentText = [realTimeCommentText copy];
    self.realtimeCommentLocationLabel.text  = realTimeCommentText;
}
@end
