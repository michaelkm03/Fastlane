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
    self.pollPreviewView.hidden = YES;
    self.mpPlayerContainmentView.hidden = YES;
    self.remixButton.hidden = YES;
    self.previewImage.hidden = YES;
    self.remixButton.hidden = YES;
    
    [self.mpController setContentURL:[NSURL URLWithString:self.currentAsset.data]];
    self.mpPlayerContainmentView.hidden = YES;
    [self.mpController prepareToPlay];
    
    [self updateActionBar];
}

- (void)mpLoadStateChanged
{
    if (self.mpController.loadState == MPMovieLoadStatePlayable && self.mpController.playbackState != MPMoviePlaybackStatePlaying)
    {
        
        CGFloat yRatio = 1;
        CGFloat xRatio = 1;
        if (self.mpController.naturalSize.height < self.mpController.naturalSize.width)
        {
            yRatio = self.mpController.naturalSize.height / self.mpController.naturalSize.width;
        }
        else if (self.mpController.naturalSize.height > self.mpController.naturalSize.width)
        {
            xRatio = self.mpController.naturalSize.width / self.mpController.naturalSize.height;
        }
        CGFloat videoHeight = fminf(self.mediaView.frame.size.height * yRatio, self.mediaView.frame.size.height);
        CGFloat videoWidth = self.mediaView.frame.size.width * xRatio;
        self.mpController.view.frame = CGRectMake(0, 0, videoWidth, videoHeight);
        self.mpController.view.center = CGPointMake(self.view.center.x, self.mpController.view.center.y);
        
        [self.mpPlayerContainmentView addSubview:self.mpController.view];
        
        [self animateVideoOpen];
    }
}

- (void)animateVideoOpen
{
    self.mpPlayerContainmentView.frame = CGRectMake(0, 0, 0, 0);
    self.mpPlayerContainmentView.hidden = NO;
    
    CGFloat duration = .5f;
    
    VLog(@"PreviewImage size: %@", NSStringFromCGSize(self.previewImage.frame.size));
    VLog(@"Natural Video size: %@", NSStringFromCGSize(self.mpController.naturalSize));
    
    [UIView animateWithDuration:duration animations:
     ^{
         self.mpPlayerContainmentView.frame = self.mpController.view.frame;
     }
                     completion:^(BOOL finished)
     {
         [self.mpController play];
         self.remixButton.hidden = NO;
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
