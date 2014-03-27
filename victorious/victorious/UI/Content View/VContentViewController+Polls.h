//
//  VContentViewController+Polls.h
//  victorious
//
//  Created by Will Long on 3/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentViewController.h"
#import "VContentViewController+Private.h"

@interface VContentViewController (Polls) <VPollAnswerBarDelegate>

- (void)pollAnimation;

- (void)loadPoll;
- (IBAction)playPoll:(id)sender;

@end
