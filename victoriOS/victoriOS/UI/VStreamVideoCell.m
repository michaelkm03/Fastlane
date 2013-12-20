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

@import MediaPlayer;

@interface VStreamVideoCell ()

@property (strong, nonatomic) MPMoviePlayerController* mpController;

@end

@implementation VStreamVideoCell

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
}

- (IBAction)pressedPlay:(id)sender
{
    if (![self.sequence.nodes count]) //If theres no nodes we need to fetch
    {
        [[[VObjectManager sharedManager] fetchSequence:self.sequence
                                         successBlock:^(NSArray *resultObjects) {
                                             [self playSequence];
                                         }
                                            failBlock:^(NSError *error) {
                                                UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Understood" otherButtonTitles:nil];
                                                [alert show];
                                            }] start];
    }
}

- (void)playSequence
{
    
    VNode* node = [[VNode orderedNodesForSequence:self.sequence] firstObject];
    VAsset* asset = [[VAsset orderedAssetsForNode:node] firstObject];
    
    _mpController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString: asset.data]];
}

@end
