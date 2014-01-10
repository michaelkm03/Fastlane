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

#import "NSString+VParseHelp.h"

@interface VStreamPollCell ()
@property (nonatomic, weak) VAnswer* firstAnswer;
@property (nonatomic, weak) VAnswer* secondAnswer;
@end

@implementation VStreamPollCell

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    NSArray* answers = [[self.sequence firstNode] firstAnswers];
    
    _firstAnswer = [answers firstObject];
    if (_firstAnswer && ![_firstAnswer.label isEmpty])
        self.optionOneButton.titleLabel.text = _firstAnswer.label;
    
    if ([answers count] >= 2)
    {
        _secondAnswer = [answers objectAtIndex:1];
        
        if (![_secondAnswer.label isEmpty])
            self.optionTwoButton.titleLabel.text = _secondAnswer.label;
    }
    
    NSString *firstUrlString, *secondUrlString;
    
    if ([self.reuseIdentifier isEqualToString:kStreamPollCellIdentifier])
    {
        //TODO: hide the cell if we fail to load the image
        VAsset* firstAsset = [self.sequence firstAsset];
        firstUrlString = firstAsset.data;
    }
    else if ([self.reuseIdentifier isEqualToString:kStreamDoublePollCellIdentifier])
    {
        firstUrlString = _firstAnswer.mediaUrl;
        secondUrlString = _secondAnswer.mediaUrl;
    }
    
    if ([firstUrlString.extensionType isEqualToString:VConstantsMediaTypeImage])
        [self.previewImageView setImageWithURL:[NSURL URLWithString:firstUrlString]];
    else
    {
        //TODO: Swap to video
        self.hidden = YES;
    }
        
    if ([secondUrlString.extensionType isEqualToString:VConstantsMediaTypeImage])
        [self.previewImageTwo setImageWithURL:[NSURL URLWithString:secondUrlString]];
    else
    {
        //TODO: Swap to video
    }
}

- (IBAction)pressedOptionOne:(id)sender
{
    [self answerPollWithAnswer:_firstAnswer];
}

- (IBAction)pressedOptionTwo:(id)sender
{
    [self answerPollWithAnswer:_secondAnswer];
}

- (void)answerPollWithAnswer:(VAnswer*)answer
{
    [[[VObjectManager sharedManager] answerPollWithAnswer:answer
                                             successBlock:^(NSArray *resultObjects)
      {
          VLog(@"Successfully answered: %@", resultObjects);
          [self showResults];
      }
                                                failBlock:^(NSError *error)
      {
          VLog(@"Failed to answer with error: %@", error);
      }] start];
}


- (void)showResults
{
    //TODO: use result object to show results.
}
@end
