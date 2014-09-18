//
//  VRealTimeCommentsCell.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VRealTimeCommentsCell.h"

@interface VRealTimeCommentsCell ()

@property (weak, nonatomic) IBOutlet UIView *realtimeCommentStrip;
@property (weak, nonatomic) IBOutlet UIImageView *currentUserAvatar;
@property (weak, nonatomic) IBOutlet UILabel *currentUserNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeAgoLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentCommentBodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentAtTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *conversationClock;


@end

@implementation VRealTimeCommentsCell

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), 92);
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.currentUserAvatar.image = nil;
    self.currentUserNameLabel.text = nil;
    self.currentCommentBodyLabel.text = nil;
    self.currentAtTimeLabel.text = nil;
    self.currentTimeAgoLabel.text = nil;
    self.conversationClock.hidden = YES;
}

#pragma mark - Public Methods

- (void)configureWithCurrentUserAvatarURL:(NSURL *)currentAvatarURL
                          currentUsername:(NSString *)username
                       currentTimeAgoText:(NSString *)timeAgoText
                       currentCommentBody:(NSString *)commentBody
                               atTimeText:(NSString *)atTimeText
{
    [self.currentUserAvatar setImageWithURL:currentAvatarURL];
    self.currentUserNameLabel.text = username;
    self.currentTimeAgoLabel.text = timeAgoText;
    self.currentCommentBodyLabel.text = commentBody;
    self.currentAtTimeLabel.text = atTimeText;
    self.conversationClock.hidden = NO;
}

- (void)addAvatarWithURL:(NSURL *)avatarURL
     withPercentLocation:(CGFloat)percentLocation
{
    
}

@end
