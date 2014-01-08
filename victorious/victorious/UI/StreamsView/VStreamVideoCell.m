//
//  VStreamVideoCell.m
//  victoriOS
//
//  Created by Will Long on 12/19/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VStreamVideoCell.h"
#import "VSequence.h"
#import "VAsset+Fetcher.h"
#import "VNode+Fetcher.h"

#import "VObjectManager+Sequence.h"

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
    if (_mpController)
        [_mpController.view removeFromSuperview]; //make sure to get rid of the old view
}

- (IBAction)pressedPlay:(id)sender
{
    if (![self.sequence.nodes count]) //If theres no nodes we need to fetch
    {
        __block UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] init];
        [self addSubview:indicator];
        indicator.center = self.center;
        [indicator startAnimating];
        
        [[[VObjectManager sharedManager] fetchSequence:self.sequence
                                         successBlock:^(NSArray *resultObjects) {
                                             [indicator stopAnimating];
                                             [indicator removeFromSuperview];
                                             [self playSequence];
                                         }
                                            failBlock:^(NSError *error) {
                                                [indicator stopAnimating];
                                                [indicator removeFromSuperview];
                                                UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Understood" otherButtonTitles:nil];
                                                [alert show];
                                            }] start];
    }
    else
    {
        [self playSequence];
    }
}

- (void)streamsWillSegue:(NSNotification *) notification
{
    [_mpController stop];
}

- (void)playSequence
{
    VNode* node = [[VNode orderedNodesForSequence:self.sequence] firstObject];
    VAsset* asset = [[VAsset orderedAssetsForNode:node] firstObject];
    
    _mpController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString: asset.data]];
    _mpController.view.frame = self.previewImageView.frame;
    [self insertSubview:_mpController.view aboveSubview:self.previewImageView];

    [_mpController play];
}

@end
