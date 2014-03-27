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

#import "VRemixTrimViewController.h"

@implementation VContentViewController (Videos)

- (void)setupVideoPlayer
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mpLoadStateChanged)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(animateVideoClosed)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    self.mpController = [[MPMoviePlayerController alloc] initWithContentURL:nil];
    self.mpController.scalingMode = MPMovieScalingModeAspectFill;
    self.mpController.view.frame = self.previewImage.frame;
    self.mpController.shouldAutoplay = NO;
    [self.mpPlayerContainmentView addSubview:self.mpController.view];
}

- (void)loadVideo
{
    [self loadImage];
    
    self.remixButton.hidden = NO;
    
    [self.mpController setContentURL:[NSURL URLWithString:self.currentAsset.data]];
    self.mpPlayerContainmentView.hidden = YES;
    [self.mpController prepareToPlay];
    
    [self updateActionBar];
}

- (void)mpLoadStateChanged
{
    if (self.mpController.loadState == MPMovieLoadStatePlayable && self.mpController.playbackState != MPMoviePlaybackStatePlaying)
    {
        self.mpController.view.frame = self.previewImage.frame;
        
        [self.mpPlayerContainmentView addSubview:self.mpController.view];
        
        [self animateVideoOpen];
    }
}

- (void)animateVideoOpen
{
    [self.mpPlayerContainmentView setSize:CGSizeMake(0, 0)];
    self.mpPlayerContainmentView.hidden = NO;
    
    CGFloat duration = [self.sequence isPoll] ? .5f : 0;//We only animate in poll videos
    
    [UIView animateWithDuration:duration animations:
     ^{
         [self.mpPlayerContainmentView setSize:CGSizeMake(self.mpController.view.frame.size.width, self.mpController.view.frame.size.height)];
     }
                     completion:^(BOOL finished)
     {
         [self.mpController play];
     }];
}

- (void)animateVideoClosed
{
    CGFloat duration = [self.sequence isPoll] ? .5f : 0;//We only animate in poll videos
    
    [UIView animateWithDuration:duration animations:
     ^{
         [self.mpPlayerContainmentView setSize:CGSizeMake(0,0)];
     }];
}

- (IBAction)pressedRemix:(id)sender
{
    UIViewController* remixVC = [VRemixTrimViewController remixViewControllerWithURL:[self.currentAsset.data mp4UrlFromM3U8]];
    [self presentViewController:remixVC animated:YES completion:
     ^{
         [self.mpController stop];
     }];
}

@end
