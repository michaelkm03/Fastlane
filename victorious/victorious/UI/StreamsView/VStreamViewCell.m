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

#import "VEphemeralTimerView.h"

NSString *kStreamsWillCommentNotification = @"kStreamsWillCommentNotification";

@interface VStreamViewCell() <VEphemeralTimerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;
@property (weak, nonatomic) IBOutlet UIImageView *dateImageView;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;

@property (nonatomic) BOOL animating;
@property (nonatomic) NSUInteger originalHeight;

@property (strong, nonatomic) NSMutableArray* commentViews;

@property (strong, nonatomic) VEphemeralTimerView* ephemeralTimerView;

@end

@implementation VStreamViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.originalHeight = self.frame.size.height;
    
    self.commentViews = [[NSMutableArray alloc] init];
    
    self.dateLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVDateFont];
    self.descriptionLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVContentTitleFont];
    self.dateImageView.image = [self.dateImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    [self.commentButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    
    self.ephemeralTimerView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([VEphemeralTimerView class]) owner:self options:nil] firstObject];
    self.ephemeralTimerView.delegate = self;
    self.ephemeralTimerView.center = self.center;
    [self addSubview:self.ephemeralTimerView];
}

- (void)contentExpired
{
    self.shadeView.backgroundColor = [UIColor whiteColor];
    self.shadeView.alpha = .5f;
}

- (void)layoutSubviews
{
    self.profileImageButton.layer.cornerRadius = CGRectGetHeight(self.profileImageButton.bounds)/2;
    self.profileImageButton.clipsToBounds = YES;
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    [self.previewImageView setImageWithURL:[NSURL URLWithString:_sequence.previewImage]
                          placeholderImage:[UIImage new]];
    [self.profileImageButton setImageWithURL:[NSURL URLWithString:self.sequence.user.pictureUrl]
                            placeholderImage:[UIImage imageNamed:@"profile_thumb"]
                                    forState:UIControlStateNormal];
    
    if ([[[_sequence firstNode] firstAsset].type isEqualToString:VConstantsMediaTypeYoutube])
        self.playButtonImage.hidden = NO;
    else
        self.playButtonImage.hidden = YES;

//    if (!self.animating)
//        self.animationImage.alpha = .5f;
    
    self.usernameLabel.text = self.sequence.user.name;
    self.descriptionLabel.text = self.sequence.name;
    self.dateLabel.text = [self.sequence.releasedAt timeSince];
    [self.commentButton setTitle:self.sequence.commentCount.stringValue forState:UIControlStateNormal];
    
    NSLog(@"Expiration date: %@", _sequence.expiresAt);
    
    if (_sequence.expiresAt)
    {
        self.ephemeralTimerView.hidden = NO;
        self.ephemeralTimerView.expireDate = _sequence.expiresAt;
        self.animationImage.hidden = YES;
        self.animationBackgroundImage.hidden = YES;
    }
    else
    {
        self.animationImage.hidden = NO;
        self.animationBackgroundImage.hidden = NO;
        self.ephemeralTimerView.hidden = YES;
    }
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

@end
