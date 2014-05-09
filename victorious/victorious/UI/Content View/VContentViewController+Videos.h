//
//  VContentViewController+Videos.h
//  victorious
//
//  Created by Will Long on 3/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentViewController.h"
#import "VCVideoPlayerView.h"

@interface VContentViewController (Videos) <VCVideoPlayerDelegate>

- (void)loadVideo;

- (IBAction)pressedRemix:(id)sender;

@end
