//
//  VStreamPollCell.m
//  victoriOS
//
//  Created by Will Long on 12/19/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VStreamPollCell.h"
#import "VSequence.h"
#import "VObjectManager+Sequence.h"

@implementation VStreamPollCell

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    if (![self.sequence.nodes count])
    {
//        [[[VObjectManager sharedManager] fetchSequence:sequence
//                                          successBlock:nil
//                                             failBlock:nil] start];
    }
    else
    {
        [self setupView];
    }
}

- (void)setupView
{
    NSURL* url = nil;
    [self.previewImageView setImageWithURL:url];
}

- (IBAction)pressedOptionOne:(id)sender
{
    
}

- (IBAction)pressedOptionTwo:(id)sender
{
    
}

@end
