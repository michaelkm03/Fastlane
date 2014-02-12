//
//  VStreamVideoCell.m
//  victoriOS
//
//  Created by Will Long on 12/19/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VStreamVideoCell.h"

#import "VAsset.h"
#import "VNode+Fetcher.h"
#import "VSequence+Fetcher.h"
#import "VMenuController.h"

#import "CastViewController.h"

@interface VStreamVideoCell ()
@property (strong, nonatomic) MPMoviePlayerController* mpController;
@end

@implementation VStreamVideoCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopPlayer:)
                                                 name:VMenuControllerDidSelectRowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopPlayer:)
                                                 name:kStreamsWillCommentNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerFinished:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    if (self.mpController)
        [self.mpController.view removeFromSuperview]; //make sure to get rid of the old view
}

- (IBAction)pressedPlay:(id)sender
{
    VAsset* asset = [[self.sequence firstNode] firstAsset];
    
    self.mpController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:asset.data]];
    //Apple test m3u8: @"http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8"]];
    [self.mpController prepareToPlay];
    self.mpController.view.frame = self.previewImageView.frame;
    [self insertSubview:self.mpController.view aboveSubview:self.previewImageView];
    
    [self.mpController play];
}

- (void)stopPlayer:(NSNotification *) notification
{
    [self.mpController stop];
}

- (void)moviePlayerFinished:(NSNotification *) notification
{
    if (notification.object == self.mpController)
    {
        [self.mpController.view removeFromSuperview];
    }
}

- (IBAction)castAction:(id)sender
{
    CastViewController* caster = [CastViewController castViewController];
    [self.parentTableViewController presentViewController:caster.navigationController animated:YES completion:nil];
    [caster setMediaToPlay:self.sequence];
}

@end
