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
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;
@property (weak, nonatomic) IBOutlet UIImageView *dateImageView;

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
    
    self.usernameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:kVDetailFont];
    self.dateLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:kVDateFont];
    self.descriptionLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:kVContentTitleFont];
    self.dateImageView.image = [self.dateImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
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

    if (!self.animating)
        self.animationImage.alpha = .5f;
    
    self.usernameLabel.text = self.sequence.user.name;
    self.descriptionLabel.text = self.sequence.name;
    self.dateLabel.text = [self.sequence.releasedAt timeSince];
    [self.previewImageView setImageWithURL:[NSURL URLWithString:_sequence.previewImage]
                          placeholderImage:[UIImage new]];
    [self.profileImageButton setImageWithURL:[NSURL URLWithString:self.sequence.user.pictureUrl]
                            placeholderImage:[UIImage imageNamed:@"profile_thumb"]
                                    forState:UIControlStateNormal];
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
        [UIView animateKeyframesWithDuration:1.4f delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear
                                  animations:^
                                  {
                                      [UIView addKeyframeWithRelativeStartTime:0      relativeDuration:.37f   animations:^{   self.animationImage.alpha = 1;      }];
                                      [UIView addKeyframeWithRelativeStartTime:.37f   relativeDuration:.21f   animations:^{   self.animationImage.alpha = .3f;    }];
                                      [UIView addKeyframeWithRelativeStartTime:.58f   relativeDuration:.17f   animations:^{   self.animationImage.alpha = .9f;    }];
                                      [UIView addKeyframeWithRelativeStartTime:.75f   relativeDuration:.14f   animations:^{   self.animationImage.alpha = .3f;    }];
                                      [UIView addKeyframeWithRelativeStartTime:.89f   relativeDuration:.11f   animations:^{   self.animationImage.alpha = .5f;    }];
                                  }
                                  completion:^(BOOL finished)
                                  {
                                      [self performSelector:@selector(firstAnimation) withObject:nil afterDelay:3.5f];
                                  }];
}

- (void)stopAnimation
{
    self.animating = NO;
}

@end
