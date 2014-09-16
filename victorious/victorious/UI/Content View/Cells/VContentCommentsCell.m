//
//  VContentCommentsCell.m
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentCommentsCell.h"

#import "VCommentTextAndMediaView.h"

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

+ (CGSize)sizeWithCommentBody:(NSString *)commentBody
{
    CGFloat size = [VCommentTextAndMediaView estimatedHeightWithWidth:200.0f
                                                                text:commentBody
                                                           withMedia:NO];
    return CGSizeMake(320.0f, size+32+11);
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.seperatorImageView.image = [self.seperatorImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.seperatorImageView.tintColor = [UIColor colorWithRed:229/255.0f green:229/255.0f blue:229/255.0f alpha:1.0f];
    
    self.commentersAvatarImageView.layer.cornerRadius = CGRectGetWidth(self.commentersAvatarImageView.bounds) * 0.5f;
    self.commentersAvatarImageView.image = [self.commentersAvatarImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.commentersAvatarImageView.tintColor = [UIColor lightGrayColor];
    
    self.commentAndMediaView.preferredMaxLayoutWidth = CGRectGetWidth(self.commentAndMediaView.frame);
}

#pragma mark - Property Accessor

- (void)setCommenterName:(NSString *)commenterName
{
    _commenterName = commenterName;
    self.commentersUsernameLabel.text = commenterName;
}

- (void)setURLForCommenterAvatar:(NSURL *)URLForCommenterAvatar
{
    _URLForCommenterAvatar = URLForCommenterAvatar;
    [self.commentersAvatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:URLForCommenterAvatar]
                                          placeholderImage:nil
                                                   success:nil
                                                   failure:nil];
}

- (void)setTimestampText:(NSString *)timestampText
{
    _timestampText = timestampText;
    self.timestampLabel.text = timestampText;
}

- (void)setRealTimeCommentText:(NSString *)realTimeCommentText
{
    _realTimeCommentText = realTimeCommentText;
    self.realtimeCommentLocationLabel.text  = realTimeCommentText;
}
@end
