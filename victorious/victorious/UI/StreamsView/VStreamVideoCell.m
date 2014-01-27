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
                                             selector:@selector(streamsWillSegue:)
                                                 name:kStreamsWillSegueNotification
                                               object:nil];
    if (self.mpController)
        [self.mpController.view removeFromSuperview]; //make sure to get rid of the old view
}

- (IBAction)pressedPlay:(id)sender
{
    VAsset* asset = [[self.sequence firstNode] firstAsset];
    
    self.mpController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:asset.data]];
    [self.mpController prepareToPlay];
    self.mpController.view.frame = self.previewImageView.frame;
    [self insertSubview:self.mpController.view aboveSubview:self.previewImageView];
    
    [self.mpController play];
}

- (void)streamsWillSegue:(NSNotification *) notification
{
    [self.mpController stop];
}

@end
