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

- (void)setupVideoPlayer
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mpLoadStateChanged)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(animateVideoClosed)
//                                                 name:MPMoviePlayerPlaybackDidFinishNotification
//                                               object:nil];
}

- (void)loadVideo
{
    [self loadImage];
    
    [self.mpController.view removeFromSuperview];
    self.mpController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.currentAsset.data]];
    self.mpController.scalingMode = MPMovieScalingModeAspectFit;
    self.mpController.view.frame = self.previewImage.frame;
    self.mpController.shouldAutoplay = NO;
    [self.mpPlayerContainmentView addSubview:self.mpController.view];
    [self.mpController prepareToPlay];
    
    self.activityIndicator.center = CGPointMake(CGRectGetMidX(self.mediaView.bounds), CGRectGetMidY(self.mediaView.bounds));
    [self.mediaView addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

- (void)mpLoadStateChanged
{
    if (self.mpController.loadState == MPMovieLoadStatePlayable && self.mpController.playbackState == MPMoviePlaybackStateStopped)
    {
        [self.activityIndicator stopAnimating];
        
        CGFloat yRatio = 1;
        yRatio = fminf(self.mpController.naturalSize.height / self.mpController.naturalSize.width, 1);
        
        CGFloat videoHeight = fminf(self.mediaView.frame.size.height * yRatio, self.mediaView.frame.size.height);
        CGFloat videoWidth = self.mediaView.frame.size.width;
        self.mpController.view.frame = CGRectMake(0, 0, videoWidth, videoHeight);
        [self animateVideoOpen];
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
         self.previewImage.frame =  self.mpController.view.frame;
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:duration animations:
          ^{
              self.mpPlayerContainmentHeightConstraint.constant = CGRectGetHeight(self.mpController.view.bounds);
              self.mpPlayerContainmentWidthConstraint.constant = CGRectGetWidth(self.mpController.view.bounds);
              [self.view layoutIfNeeded];
          }
                          completion:^(BOOL finished)
          {
              [self.mpController play];
              self.remixButton.hidden = NO;
          }];
     }];
}

- (void)animateVideoClosed
{
    CGFloat duration = [self.sequence isPoll] ? .5f : 0;//We only animate in poll videos
    
    [UIView animateWithDuration:duration animations:
     ^{
         self.mpPlayerContainmentView.bounds = CGRectMake(0, 0, 0, 0);
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
         [self.mpController pause];
     }];
}

@end
