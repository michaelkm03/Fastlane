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
#import "VPollResult.h"
#import "VUser.h"

#import "VLoginViewController.h"

#import "NSString+VParseHelp.h"

#import "UIView+AutoLayout.h"

#import "VThemeManager.h"

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
    
    NSArray* answers = [[self.sequence firstNode] firstAnswers];
    _firstAnswer = [answers firstObject];
    if ([answers count] >= 2)
    {
        _secondAnswer = [answers objectAtIndex:1];
    }
    
    if (_mpControllerOne)
        [_mpControllerOne.view removeFromSuperview]; //make sure to get rid of the old view
    
    if (_mpControllerTwo)
        [_mpControllerTwo.view removeFromSuperview]; //make sure to get rid of the old view
    
    [self setupMedia];
    [self setupOrLabel];
    [self setupResultLabels];
    [self setupOptionButtons];
}

- (void)setupMedia
{
    VAsset* firstAsset = [self.sequence firstAsset];
    if (firstAsset)
    {
        //TODO: hide the cell if we fail to load the image
        _firstAssetUrl = firstAsset.data;
    }
    else
    {
        _firstAssetUrl = _firstAnswer.mediaUrl;
        _secondAssetUrl = _secondAnswer.mediaUrl;
    }
    
    if ([[_firstAssetUrl pathExtension] isEqualToString:VConstantMediaExtensionM3U8])
    {
        self.playOneButton.hidden = NO;
        [self.previewImageView setImageWithURL:[NSURL URLWithString:[_firstAssetUrl previewImageURLForM3U8]]];
    }
    else
    {
        self.playOneButton.hidden = YES;
        [self.previewImageView setImageWithURL:[NSURL URLWithString:_firstAssetUrl]];
    }
    
    if ([[_secondAssetUrl pathExtension] isEqualToString:VConstantMediaExtensionM3U8])
    {
        self.playTwoButton.hidden = NO;
        [self.previewImageTwo setImageWithURL:[NSURL URLWithString:[_secondAssetUrl previewImageURLForM3U8]]];
    }
    else
    {
        self.playTwoButton.hidden = YES;
        [self.previewImageTwo setImageWithURL:[NSURL URLWithString:_secondAssetUrl]];
    }
}

- (void)setupOrLabel
{
    CGSize orLabelSize = CGSizeMake(38, 38);
    UILabel *orLabel = [UILabel autoLayoutView];
    orLabel.textAlignment = NSTextAlignmentCenter;
    orLabel.layer.cornerRadius = orLabelSize.height/2;
    orLabel.layer.borderWidth = 2;
    orLabel.layer.borderColor = [[[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.poll.or.border"] CGColor];
    orLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.text.post.poll.or"];
    orLabel.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.poll.or.background"];
    orLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.post.poll.or"];
    orLabel.text = NSLocalizedString(@"OR", @"Poll OR");
    [self.answerView addSubview:orLabel];
    [orLabel constrainToSize:orLabelSize];
    [orLabel centerInContainerOnAxis:NSLayoutAttributeCenterX];
    [orLabel centerInContainerOnAxis:NSLayoutAttributeCenterY];
}

- (void)setupResultLabels
{
    self.firstResultLabel.font = self.secondResultLabel.font =
            [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.poll.result.badge"];
    self.firstResultLabel.textColor = self.secondResultLabel.textColor =
            [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.menu.badge.text"];
    self.firstResultLabel.backgroundColor = self.secondResultLabel.backgroundColor =
            [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.poll.result.default"];
            //[[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.post.poll.or.border"];
    self.firstResultLabel.text = self.secondResultLabel.text = @"100%";
    
    self.firstResultLabel.hidden = self.secondResultLabel.hidden = YES;
}

- (void)setupOptionButtons
{
    self.optionOneButton.tintColor = self.optionTwoButton.tintColor = [UIColor whiteColor];
    
    if (_firstAnswer.label)
        self.optionOneButton.titleLabel.text = _firstAnswer.label;
    if (_secondAnswer.label)
        self.optionTwoButton.titleLabel.text = _secondAnswer.label;
    
    self.optionOneButton.titleLabel.textAlignment = self.optionTwoButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.optionOneButton.backgroundColor = self.optionTwoButton.backgroundColor =
        [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.poll.result.default"];
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
    self.mpControllerOne = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:_firstAssetUrl]];
    [self.mpControllerOne prepareToPlay];
    self.mpControllerOne.view.frame = self.previewImageView.frame;
    [self.mediaView insertSubview:self.mpControllerOne.view aboveSubview:self.previewImageView];
    
    [self.mpControllerOne play];
    self.playOneButton.hidden = YES;
}
- (IBAction)pressedPlayTwo:(id)sender
{
    self.mpControllerTwo = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:_secondAssetUrl]];
    [self.mpControllerTwo prepareToPlay];
    self.mpControllerTwo.view.frame = self.previewImageTwo.frame;
    [self.mediaView insertSubview:self.mpControllerTwo.view aboveSubview:self.previewImageTwo];
    
    [self.mpControllerTwo play];
    self.playTwoButton.hidden = YES;
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
          [[[VObjectManager sharedManager] pollResultsForSequence:self.sequence
                                                    successBlock:^(NSArray *resultObjects)
                                                    {
                                                        [self showResultsForAnswer:answer];
                                                    }
                                                        failBlock:^(NSError *error)
                                                        {
                                                            VLog(@"Failed with error: %@", error);
                                                        }] start];
          
          VLog(@"Successfully answered: %@", resultObjects);
      }
                                      failBlock:^(NSError *error)
      {
          //Error 1005 is "Poll result was already recorded.
          //If we get anything else... lie and say we already answered
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
    NSInteger totalVotes = 0;
    for( VPollResult* result in self.sequence.pollResults)
    {
        totalVotes+= result.count.integerValue;
    }
    totalVotes = totalVotes ? totalVotes : 1; //dividing by 0 is bad.
    
    for( VPollResult* result in self.sequence.pollResults)
    {
        VInboxBadgeLabel* label = [self resultLabelForAnswerID:result.answerId];
        
        NSInteger percentage = (result.count.doubleValue / totalVotes) * 100;
        percentage = percentage > 100 ? 100 : percentage;
        percentage = percentage < 0 ? 0 : percentage;
        
        label.text = [@(percentage).stringValue stringByAppendingString:@"%"];
        //unhide both flags
        if (result.answerId == answer.remoteId)
        {
            label.backgroundColor =
                    [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color"];
        }
    }
    self.firstResultLabel.hidden = self.secondResultLabel.hidden = NO;
    
    if ([answer.remoteId isEqualToNumber:_firstAnswer.remoteId])
    {
        self.optionOneButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color"];
    }
    else
    {
        self.optionTwoButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color"];
    }
}

- (VInboxBadgeLabel*)resultLabelForAnswerID:(NSNumber*)answerID
{
    if ([answerID isEqualToNumber:_firstAnswer.remoteId])
        return _firstResultLabel;
    else if ([answerID isEqualToNumber:_secondAnswer.remoteId])
        return  _secondResultLabel;
    
    return nil;
}

- (void)streamsWillSegue:(NSNotification *) notification
{
    [self.mpControllerOne stop];
    [self.mpControllerTwo stop];
}

@end
