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

#import "VLoginViewController.h"

#import "NSString+VParseHelp.h"

@import MediaPlayer;

@interface VStreamPollCell ()
@property (nonatomic, weak) VAnswer* firstAnswer;
@property (nonatomic, weak) VAnswer* secondAnswer;

@property (nonatomic, copy) NSString* firstAssetUrl;
@property (nonatomic, copy) NSString* secondAssetUrl;

@property (nonatomic, strong) MPMoviePlayerController* mpControllerOne;
@property (nonatomic, strong) MPMoviePlayerController* mpControllerTwo;
@end

@implementation VStreamPollCell

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    NSArray* answers = [[self.sequence firstNode] firstAnswers];

    self.optionOneButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.optionTwoButton.titleLabel.textAlignment = NSTextAlignmentCenter;

    _firstAnswer = [answers firstObject];
    self.optionOneButton.titleLabel.text = _firstAnswer.label;
    
    if ([answers count] >= 2)
    {
        _secondAnswer = [answers objectAtIndex:1];
        
        self.optionTwoButton.titleLabel.text = _secondAnswer.label;
    }
    
    if ([self.reuseIdentifier isEqualToString:kStreamPollCellIdentifier])
    {
        //TODO: hide the cell if we fail to load the image
        VAsset* firstAsset = [self.sequence firstAsset];
        _firstAssetUrl = firstAsset.data;
    }
    else if ([self.reuseIdentifier isEqualToString:kStreamDoublePollCellIdentifier])
    {
        _firstAssetUrl = _firstAnswer.mediaUrl;
        _secondAssetUrl = _secondAnswer.mediaUrl;
    }
    
    if ([_firstAssetUrl.extensionType isEqualToString:VConstantsMediaTypeVideo])
    {
        self.playOneButton.hidden = NO;
        [self.previewImageView setImageWithURL:[NSURL URLWithString:[_firstAssetUrl previewImageURLForM3U8]]];
        
        self.mpControllerOne = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:_firstAssetUrl]];
//        [self.mpControllerOne prepareToPlay];
        self.mpControllerOne.view.frame = self.previewImageView.frame;
        [self insertSubview:self.mpControllerOne.view belowSubview:self.previewImageView];
        self.mpControllerOne.view.hidden = YES;
    }
    else
    {
        self.playOneButton.hidden = YES;
        [self.previewImageView setImageWithURL:[NSURL URLWithString:_firstAssetUrl]];
    }
    
    if ([_secondAssetUrl.extensionType isEqualToString:VConstantsMediaTypeVideo])
    {
        self.playTwoButton.hidden = NO;
        [self.previewImageTwo setImageWithURL:[NSURL URLWithString:[_secondAssetUrl previewImageURLForM3U8]]];
        
        self.mpControllerTwo = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:_secondAssetUrl]];
//        [self.mpControllerTwo prepareToPlay];
        self.mpControllerTwo.view.frame = self.previewImageTwo.frame;
        [self.previewImageTwo insertSubview:self.mpControllerTwo.view belowSubview:self.previewImageTwo];
        self.mpControllerTwo.view.hidden = YES;
    }
    else
    {
        self.playTwoButton.hidden = YES;
        [self.previewImageView setImageWithURL:[NSURL URLWithString:_secondAssetUrl]];
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

- (IBAction)pressedPlayOne:(id)sender
{
    self.mpControllerOne.view.hidden = NO;
    self.previewImageView.hidden = YES;
    [_mpControllerOne play];
}
- (IBAction)pressedPlayTwo:(id)sender
{
    self.mpControllerTwo.view.hidden = NO;
    self.previewImageView.hidden = YES;
    [_mpControllerTwo play];
}

- (void)answerPollWithAnswer:(VAnswer*)answer
{
    if(![VObjectManager sharedManager].mainUser)
    {
        [self.parentTableViewController presentViewController:[VLoginViewController sharedLoginViewController] animated:YES completion:NULL];
        return;
    }
    
    [[[VObjectManager sharedManager] answerPoll:self.sequence
                                     withAnswer:answer
                                   successBlock:^(NSArray *resultObjects)
      {
          VLog(@"Successfully answered: %@", resultObjects);
          [self showResultsForAnswer:answer];
      }
                                                failBlock:^(NSError *error)
      {
          //Error 1005 is "Poll result was already recorded
          if (error.code == 1005)
              [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PollAlreadyAnswered", @"")
                                          message:error.localizedDescription
                                         delegate:nil
                                cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                otherButtonTitles:nil] show];
          
          VLog(@"Failed to answer with error: %@", error);
      }] start];
}

- (void)showResultsForAnswer:(VAnswer*)answer
{
    //TODO: use result object to show results.
    answer;
}
@end
