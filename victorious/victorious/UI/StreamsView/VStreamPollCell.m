//
//  VStreamPollCell.m
//  victoriOS
//
//  Created by Will Long on 12/19/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VStreamPollCell.h"

#import "VSequence+Fetcher.h"
#import "VObjectManager+Sequence.h"

#import "VNode+Fetcher.h"

#import "VInteraction.h"
#import "VAnswer.h"
#import "VAsset.h"

@implementation VStreamPollCell

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    NSArray* answers = [[self.sequence firstNode] firstAnswers];
    
    VAnswer* firstAnswer = [answers firstObject];
    if (firstAnswer)
        self.optionOneButton.titleLabel.text = firstAnswer.label;
    
    VAnswer* secondAnswer;
    if ([answers count] >= 2)
    {
        secondAnswer = [answers objectAtIndex:1];
        self.optionTwoButton.titleLabel.text = secondAnswer.label;
    }
    
    NSURL *firstImageUrl, *secondImageUrl;
    
    if ([self.reuseIdentifier isEqualToString:kStreamPollCellIdentifier])
    {
        //TODO: hide the cell if we fail to load the image
        VAsset* firstAsset = [self.sequence firstAsset];
        firstImageUrl = [NSURL URLWithString:firstAsset.data];
    }
    else if ([self.reuseIdentifier isEqualToString:kStreamDoublePollCellIdentifier])
    {
//        firstImageUrl = [NSURL URLWithString:firstAnswer.mediaUrl];
//        secondImageUrl = [NSURL URLWithString:firstAsset.mediaUrl];
    }
    
    [self.previewImageView setImageWithURL:firstImageUrl];
    [self.previewImageTwo setImageWithURL:secondImageUrl];
    
}

- (IBAction)pressedOptionOne:(id)sender
{
    
}

- (IBAction)pressedOptionTwo:(id)sender
{
    
}

@end
