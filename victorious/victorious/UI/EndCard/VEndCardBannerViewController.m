//
//  VEndCardBannerViewController.m
//  AutoplayNext
//
//  Created by Patrick Lynch on 1/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEndCardBannerViewController.h"
#import "VCountdownViewController.h"
#import "VEndCardModel.h"

@interface VEndCardBannerViewController() <VCountDownViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *upNextPromptContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upNextPromptContainerXConstraint;
@property (weak, nonatomic) IBOutlet UIView *videoInfoContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoInfoContainerXConstraint;
@property (nonatomic, assign) CGFloat videoInfoContainerXConstraintMax;

@property (weak, nonatomic) IBOutlet UIImageView *videoThumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *playlistTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *nextVideoTitleTextView;
@property (weak, nonatomic) IBOutlet UILabel *nextVideoAuthorNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *nextVideoAuthorImageView;
@property (weak, nonatomic) IBOutlet VCountdownViewController *countdownViewController;

@end

@implementation VEndCardBannerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.videoInfoContainer.alpha = 0.0;
    self.videoInfoContainerXConstraint.constant = 30.0f;
    [self.videoInfoContainer layoutIfNeeded];
    
    self.countdownViewController.delegate = self;
    
    self.videoInfoContainerXConstraintMax = self.videoInfoContainerXConstraint.constant;
    
    self.nextVideoAuthorImageView.layer.cornerRadius = CGRectGetWidth( self.nextVideoAuthorImageView.frame ) * 0.5f;
    self.nextVideoAuthorImageView.clipsToBounds = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.destinationViewController isKindOfClass:[VCountdownViewController class]] )
    {
        self.countdownViewController = (VCountdownViewController *)segue.destinationViewController;
    }
}

- (void)startCountdownWithDuration:(NSUInteger)duration
{
    NSTimeInterval durationSeconds = (float)duration / 1000.0f;
    [self.countdownViewController startTimerWithDuration:durationSeconds];
}

- (void)stopCountdown
{
    [self.countdownViewController stopTimer];
}

- (void)countDownComplete
{
    [self.countdownViewController stopTimer];
    [self.delegate nextVideoSelected];
}

- (void)showNextVideoDetails
{
    [UIView animateWithDuration:1.0f
                          delay:0.0f
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.5
                        options:kNilOptions
                     animations:^void
     {
         self.upNextPromptContainer.alpha = 0.0f;
     } completion:nil];
    
    [UIView animateWithDuration:0.5f
                          delay:0.25f
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.5
                        options:kNilOptions
                     animations:^void
     {
         self.videoInfoContainer.alpha = 1.0f;
         self.videoInfoContainerXConstraint.constant = 0.0f;
         [self.videoInfoContainer layoutIfNeeded];
     } completion:nil];
}

- (void)resetNextVideoDetails
{
    self.upNextPromptContainer.alpha = 1.0f;
    self.videoInfoContainer.alpha = 0.0f;
    self.videoInfoContainerXConstraint.constant = self.videoInfoContainerXConstraintMax;
    [self.videoInfoContainer layoutIfNeeded];
}

#pragma mark - Setters

- (void)configureWithModel:(VEndCardModel *)model
{
    self.nextVideoTitleTextView.text = model.nextVideoTitle;
    self.playlistTitleLabel.text = model.streamName;
    self.nextVideoAuthorNameLabel.text = model.videoAuthorName;
    self.videoThumbnailImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:model.nextVideoThumbailImageURL]];
    self.nextVideoAuthorImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:model.videoAuthorProfileImageURL]];
    self.view.backgroundColor = model.bannerBackgroundColor;
}

#pragma mark - Actions

- (IBAction)onNextTapped:(id)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        [self.delegate nextVideoSelected];
    });
}

@end
