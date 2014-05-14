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
    self.videoPlayer = [[VCVideoPlayerView alloc] initWithFrame:self.previewImage.frame];
    self.videoPlayer.delegate = self;
    [self.videoPlayer setItemURL:[NSURL URLWithString:self.currentAsset.data]];
    [self.mpPlayerContainmentView addSubview:self.videoPlayer];
    
    [self.mediaView addSubview:self.activityIndicator];
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.mediaView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1
                                                                constant:0];
    [self.mediaView addConstraint:centerX];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.mediaView
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1
                                                                constant:0];
    [self.mediaView addConstraint:centerY];
    [self.activityIndicator startAnimating];
}

- (BOOL)isVideoLoadingOrLoaded
{
    return self.videoPlayer || self.previewImageTemporaryHeightConstraint;
}

- (void)unloadVideoWithDuration:(NSTimeInterval)duration
{
    [self.videoPlayer removeFromSuperview];
    self.videoPlayer = nil;
    if (self.previewImageTemporaryHeightConstraint)
    {
        [UIView animateWithDuration:duration
                        delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^(void)
        {
            [self.previewImage removeConstraint:self.previewImageTemporaryHeightConstraint];
            [self.view layoutIfNeeded];
        }
                         completion:nil];
    }
}

- (void)animateVideoOpen
{
    self.mpPlayerContainmentHeightConstraint.constant = 0;
    self.mpPlayerContainmentWidthConstraint.constant = 0;
    [self.view layoutIfNeeded];
    self.mpPlayerContainmentView.hidden = NO;
    
    CGFloat duration = .5f;
    
    [self.previewImage cancelImageRequestOperation];
    
    [UIView animateWithDuration:.2f
                     animations:^
     {
         NSLayoutConstraint *temporaryHeightConstraint = [NSLayoutConstraint constraintWithItem:self.previewImage
                                                                                      attribute:NSLayoutAttributeHeight
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:nil
                                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                                     multiplier:1.0f
                                                                                       constant:CGRectGetHeight(self.videoPlayer.bounds)];
         [self.previewImage addConstraint:temporaryHeightConstraint];
         self.previewImageTemporaryHeightConstraint = temporaryHeightConstraint;
         [self.view layoutIfNeeded];
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:duration animations:
          ^{
              self.mpPlayerContainmentHeightConstraint.constant = CGRectGetHeight(self.videoPlayer.bounds);
              self.mpPlayerContainmentWidthConstraint.constant = CGRectGetWidth(self.videoPlayer.bounds);
              [self.view layoutIfNeeded];
          }
                          completion:^(BOOL finished)
          {
              [self.videoPlayer.player play];
              self.remixButton.hidden = NO;
          }];
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
    
    CGFloat yRatio = 1;
    yRatio = fminf(self.videoPlayer.naturalSize.height / self.videoPlayer.naturalSize.width, 1);
    
    CGFloat videoHeight = fminf(self.mediaView.frame.size.height * yRatio, self.mediaView.frame.size.height);
    CGFloat videoWidth = self.mediaView.frame.size.width;
    self.videoPlayer.frame = CGRectMake(0, 0, videoWidth, videoHeight);
    [self animateVideoOpen];
}

@end
