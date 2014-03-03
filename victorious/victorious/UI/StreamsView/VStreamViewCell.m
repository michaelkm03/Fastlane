//
//  VStreamViewCell.m
//  victoriOS
//
//  Created by David Keegan on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VStreamViewCell.h"
#import "VSequence.h"
#import "VObjectManager+Sequence.h"
#import "VThemeManager.h"
#import "NSDate+timeSince.h"
#import "VUser.h"

#import "VProfileViewController.h"

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"

#import "UIButton+VImageLoading.h"

#import "VConstants.h"

#import "VCommentCell.h"

NSString *kStreamsWillCommentNotification = @"kStreamsWillCommentNotification";
@interface VStreamViewCell()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;

@property (nonatomic) BOOL animating;
@property (nonatomic) NSUInteger originalHeight;

@property (strong, nonatomic) NSMutableArray* commentViews;

@end

@implementation VStreamViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.originalHeight = self.frame.size.height;
    
    self.commentViews = [[NSMutableArray alloc] init];
    
    self.usernameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:kVStreamUsernameFont];
    self.locationLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:kVStreamLocationFont];
    self.dateLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:kVStreamDateFont];
    self.descriptionLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:kVStreamDescriptionFont];
    
}

- (void)layoutSubviews
{
    self.profileImageButton.layer.cornerRadius = CGRectGetHeight(self.profileImageButton.bounds)/2;
    self.profileImageButton.clipsToBounds = YES;
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    if ([[[_sequence firstNode] firstAsset].type isEqualToString:VConstantsMediaTypeYoutube])
        self.playButtonImage.hidden = NO;
    else
        self.playButtonImage.hidden = YES;

    self.animationImage.alpha = .5f;
    self.animating = NO;
    
    self.usernameLabel.text = self.sequence.user.name;
    self.locationLabel.text = self.sequence.user.location;
    self.descriptionLabel.text = self.sequence.name;
    self.dateLabel.text = [self.sequence.releasedAt timeSince];
    [self.previewImageView setImageWithURL:[NSURL URLWithString:_sequence.previewImage]
                          placeholderImage:[UIImage new]];
    [self.profileImageButton setImageWithURL:[NSURL URLWithString:self.sequence.user.pictureUrl]
                            placeholderImage:[UIImage imageNamed:@"profile_thumb"]
                                    forState:UIControlStateNormal];
    
//    [self addCommentViews];
}

- (void)setHeight:(CGFloat)height
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

- (IBAction)commentButtonAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kStreamsWillCommentNotification object:self];
}

- (IBAction)profileButtonAction:(id)sender
{
    VProfileViewController* profileViewController = [VProfileViewController profileWithUserID:[self.sequence.createdBy integerValue]];
    [self.parentTableViewController.navigationController pushViewController:profileViewController animated:YES];
}

- (void)startAnimation
{
    //If we are already animating just ignore this and continue from where we are.
    if (self.animating)
        return;
        
    self.animating = YES;
    [self firstAnimation];
}

- (void)firstAnimation
{
    if (self.animating)
        [UIView animateWithDuration:.5f
                         animations:^{
                             self.animationImage.alpha = 1.0f;
                         }
                         completion:^(BOOL finished) {
                             [self secondAnimation];
                         }];
}

- (void)secondAnimation
{
    if (self.animating)
        [UIView animateWithDuration:.3f
                         animations:^{
                             self.animationImage.alpha = .3f;
                         }
                         completion:^(BOOL finished) {
                             [self thirdAnimation];
                         }];
}

- (void)thirdAnimation
{
    if (self.animating)
        [UIView animateWithDuration:.25f
                         animations:^{
                             self.animationImage.alpha = 0.9f;
                         }
                         completion:^(BOOL finished) {
                             [self fourthAnimation];
                         }];
}

- (void)fourthAnimation
{
    if (self.animating)
        [UIView animateWithDuration:.2f
                         animations:^{
                             self.animationImage.alpha = .3f;
                         }
                         completion:^(BOOL finished) {
                             [self fifthAnimation];
                         }];
}

- (void)fifthAnimation
{
    if (self.animating)
        [UIView animateWithDuration:.15f
                         animations:^{
                             self.animationImage.alpha = .5f;
                         }
                         completion:^(BOOL finished) {
                             [self performSelector:@selector(firstAnimation) withObject:nil afterDelay:3.5f];
                         }];
}

- (void)stopAnimation
{
    self.animating = NO;
}
@end
