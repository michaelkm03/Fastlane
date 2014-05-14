//
//  VContentViewController+Videos.m
//  victorious
//
//  Created by Will Long on 3/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentViewController+Videos.h"
#import "VContentViewController+Private.h"
#import "VContentViewController+Images.h"
#import "VObjectManager+Users.h"
#import "VLoginViewController.h"

#import "VRemixSelectViewController.h"

@implementation VContentViewController (Videos)

- (void)loadVideo
{
    [self loadImage];
    
    [self.videoPlayer removeFromSuperview];
    self.videoPlayer = [[VCVideoPlayerView alloc] init];
    self.videoPlayer.delegate = self;
    self.videoPlayer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mediaView addSubview:self.videoPlayer];
    
    [self.mediaView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayer
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.previewImage
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:1.0f
                                                                constant:0.0f]];
    [self.mediaView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayer
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.previewImage
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:1.0f
                                                                constant:0.0f]];
    [self.mediaView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayer
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.previewImage
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1.0f
                                                                constant:0.0f]];
    [self.mediaView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayer
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.previewImage
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0f
                                                                constant:0.0f]];
    self.videoPlayer.alpha = 0;
    [self.videoPlayer setItemURL:[NSURL URLWithString:self.currentAsset.data]];
    
    [self.mediaView addSubview:self.activityIndicator];
    [self.mediaView addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.mediaView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1
                                                                constant:0]];
    [self.mediaView addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.mediaView
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1
                                                                constant:0]];
    [self.activityIndicator startAnimating];
}

- (BOOL)isVideoLoadingOrLoaded
{
    return self.videoPlayer || self.previewImageTemporaryHeightConstraint;
}

- (void)unloadVideoWithDuration:(NSTimeInterval)duration
{
    if (!self.videoPlayer && !self.previewImageTemporaryHeightConstraint)
    {
        return;
    }
    
    void (^removeVideoPlayer)(BOOL) = ^(BOOL complete)
    {
        [self.videoPlayer removeFromSuperview];
        self.videoPlayer = nil;
    };

    if (self.previewImageTemporaryHeightConstraint)
    {
        [UIView animateWithDuration:duration
                        delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^(void)
        {
            [self.previewImage removeConstraint:self.previewImageTemporaryHeightConstraint];
            [self.view layoutIfNeeded];
            self.previewImage.alpha = 1.0f;
            self.videoPlayer.alpha = 0;
        }
                         completion:removeVideoPlayer];
    }
    else
    {
        removeVideoPlayer(YES);
    }
}

- (void)animateVideoOpenToHeight:(CGFloat)height
{
    [UIView animateWithDuration:0.2f
                     animations:^(void)
    {
        NSLayoutConstraint *temporaryHeightConstraint = [NSLayoutConstraint constraintWithItem:self.previewImage
                                                                                     attribute:NSLayoutAttributeHeight
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:nil
                                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                                    multiplier:1.0f
                                                                                      constant:height];
        [self.previewImage addConstraint:temporaryHeightConstraint];
        self.previewImageTemporaryHeightConstraint = temporaryHeightConstraint;
        [self.view layoutIfNeeded];
        self.previewImage.alpha = 0;
        self.videoPlayer.alpha = 1.0f;
    }
                     completion:^(BOOL finished)
    {
         [self.videoPlayer.player play];
         self.remixButton.hidden = NO;
    }];
}

- (IBAction)pressedRemix:(id)sender
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }

    UIViewController* remixVC = [VRemixSelectViewController remixViewControllerWithURL:[self.currentAsset.data mp4UrlFromM3U8] sequenceID:[self.sequence.remoteId integerValue] nodeID:[self.currentNode.remoteId integerValue]];
    [self presentViewController:remixVC animated:YES completion:
     ^{
         [self.videoPlayer.player pause];
     }];
}

#pragma mark - VCVideoPlayerDelegate methods

- (void)videoPlayerReadyToPlay:(VCVideoPlayerView *)videoPlayer
{
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    
    CGFloat yRatio = fminf(self.videoPlayer.naturalSize.height / self.videoPlayer.naturalSize.width, 1);
    
    CGFloat videoHeight = CGRectGetHeight(self.mediaView.frame) * yRatio;
    [self animateVideoOpenToHeight:videoHeight];
}

@end
