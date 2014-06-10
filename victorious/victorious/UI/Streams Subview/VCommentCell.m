//
//  VCommentCell.m
//  victoriOS
//
//  Created by David Keegan on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

@import MediaPlayer;

#import "VCommentCell.h"
#import "VConstants.h"

#import "VComment+Fetcher.h"
#import "VUser+RestKit.h"

#import "NSDate+timeSince.h"

#import "UIButton+VImageLoading.h"
#import "UIImage+ImageCreation.h"

#import "VThemeManager.h"

CGFloat const kCommentMinCellHeight = 72;
CGFloat const kCommentCellYOffset = 52;
CGFloat const kCommentMediaCellYOffset = 236;

@interface VCommentCell()

@property (strong, nonatomic) UIImageView *chatBubble;

@end

@implementation VCommentCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.comment = self.comment;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.comment = self.comment;
    CGFloat yOffset = [self.comment previewImageURL] ? kCommentMediaCellYOffset : kCommentCellYOffset;
    
    CGSize size = [VAbstractCommentCell frameSizeForMessageText:self.messageLabel.text];
    self.messageLabel.frame = CGRectMake(CGRectGetMinX(self.messageLabel.frame), CGRectGetMinY(self.messageLabel.frame),
                                         size.width, size.height);
    [self.messageLabel sizeToFit];
    
    CGFloat height = MAX(self.messageLabel.frame.size.height + yOffset, kCommentMinCellHeight);
    self.bounds = CGRectMake(0, 0, self.frame.size.width, height);
}

- (void)setComment:(VComment *)comment
{
    self.mpController = nil;
    
    _comment = comment;
    NSString* mediaType;
    
    self.dateLabel.text = [comment.postedAt timeSince];
    self.nameLabel.text = comment.user.name;
    self.messageLabel.text = comment.text;
    self.mediaUrl = comment.mediaUrl ? [NSURL URLWithString:comment.mediaUrl] : nil;
    self.previewImageUrl = [comment previewImageURL];
    self.user = comment.user;
    
    mediaType = comment.mediaType;
    
    [self.profileImageButton setImageWithURL:[NSURL URLWithString:self.user.pictureUrl]
                            placeholderImage:[UIImage imageNamed:@"profile_thumb"]
                                    forState:UIControlStateNormal];
    if (self.previewImageUrl)
    {
        self.mediaPreview.hidden = NO;
        
        self.playButton.hidden = ![mediaType isEqualToString:VConstantsMediaTypeVideo];
        
        [self.mediaPreview setImageWithURL:self.previewImageUrl
                          placeholderImage:[UIImage resizeableImageWithColor:
                                            [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]]];
    }
    else
    {
        self.mediaUrl = nil;
        self.mediaPreview.hidden = YES;
        self.playButton.hidden = YES;
    }
}

@end
