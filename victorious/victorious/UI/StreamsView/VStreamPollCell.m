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
    self.firstAnswer = [answers firstObject];
    if ([answers count] >= 2)
    {
        self.secondAnswer = answers[1];
    }
    
    if (self.mpControllerOne)
        [self.mpControllerOne.view removeFromSuperview]; //make sure to get rid of the old view
    
    if (self.mpControllerTwo)
        [self.mpControllerTwo.view removeFromSuperview]; //make sure to get rid of the old view
    
    [self setupMedia];
    [self setupOrLabel];
    [self setupResultLabels];
    [self setupOptionButtons];
    [self checkIfAnswered];
}

- (void)setupMedia
{
    VAsset* firstAsset = [self.sequence firstAsset];
    if (firstAsset)
    {
        //TODO: hide the cell if we fail to load the image
        self.firstAssetUrl = firstAsset.data;
    }
    else
    {
        self.firstAssetUrl = self.firstAnswer.mediaUrl;
        self.secondAssetUrl = self.secondAnswer.mediaUrl;
    }
    
    if ([[self.firstAssetUrl pathExtension] isEqualToString:VConstantMediaExtensionM3U8])
    {
        self.playOneButton.hidden = NO;
        [self.previewImageView setImageWithURL:[NSURL URLWithString:[self.firstAssetUrl previewImageURLForM3U8]]];
    }
    else
    {
        self.playOneButton.hidden = YES;
        [self.previewImageView setImageWithURL:[NSURL URLWithString:self.firstAssetUrl]];
    }
    
    if ([[self.secondAssetUrl pathExtension] isEqualToString:VConstantMediaExtensionM3U8])
    {
        self.playTwoButton.hidden = NO;
        [self.previewImageTwo setImageWithURL:[NSURL URLWithString:[self.secondAssetUrl previewImageURLForM3U8]]];
    }
    else
    {
        self.playTwoButton.hidden = YES;
        [self.previewImageTwo setImageWithURL:[NSURL URLWithString:self.secondAssetUrl]];
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
    self.firstResultLabel.text = self.secondResultLabel.text = @"0%";
    
    self.firstResultLabel.hidden = self.secondResultLabel.hidden = YES;
}

- (void)setupOptionButtons
{
    self.optionOneButton.tintColor = self.optionTwoButton.tintColor = [UIColor whiteColor];
    
    if (self.firstAnswer.label)
        self.optionOneButton.titleLabel.text = self.firstAnswer.label;
    if (self.secondAnswer.label)
        self.optionTwoButton.titleLabel.text = self.secondAnswer.label;
    
    self.optionOneButton.titleLabel.textAlignment = self.optionTwoButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.optionOneButton.backgroundColor = self.optionTwoButton.backgroundColor =
        [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.poll.result.default"];
}

- (void)checkIfAnswered
{
    for (VPollResult* result in [VObjectManager sharedManager].mainUser.pollResults)
    {
        if ([result.sequenceId isEqualToNumber: self.sequence.remoteId])
        {
            [self showResultsForAnswerId:result.answerId];
        }
    }
}

- (IBAction)pressedOptionOne:(id)sender
{
    [self answerPollWithAnswer:self.firstAnswer];
}

- (IBAction)pressedOptionTwo:(id)sender
{
    [self answerPollWithAnswer:self.secondAnswer];
}

- (IBAction)pressedPlayOne:(id)sender
{
    //Only play for video
    if (![[self.firstAssetUrl pathExtension] isEqualToString:VConstantMediaExtensionM3U8])
        return;
    
    self.mpControllerOne = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.firstAssetUrl]];
    [self.mpControllerOne prepareToPlay];
    self.mpControllerOne.view.frame = self.previewImageView.frame;
    [self.mediaView insertSubview:self.mpControllerOne.view aboveSubview:self.previewImageView];
    
    [self.mpControllerOne play];
    self.playOneButton.hidden = YES;
    
    if (self.mpControllerTwo.view.superview)
    {
        [self.mpControllerTwo.view removeFromSuperview];
        self.playTwoButton.hidden = NO;
    }
}

- (IBAction)pressedPlayTwo:(id)sender
{
    //Only play for video
    if (![[self.secondAssetUrl pathExtension] isEqualToString:VConstantMediaExtensionM3U8])
        return;
    
    
    self.mpControllerTwo = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.secondAssetUrl]];
    [self.mpControllerTwo prepareToPlay];
    self.mpControllerTwo.view.frame = self.previewImageTwo.frame;
    [self.mediaView insertSubview:self.mpControllerTwo.view aboveSubview:self.previewImageTwo];
    
    [self.mpControllerTwo play];
    self.playTwoButton.hidden = YES;
    
    if (self.mpControllerOne.view.superview)
    {
        [self.mpControllerOne.view removeFromSuperview];
        self.playOneButton.hidden = NO;
    }
}

- (void)answerPollWithAnswer:(VAnswer*)answer
{
    if(![VObjectManager sharedManager].mainUser)
    {
        [self.parentTableViewController presentViewController:[VLoginViewController sharedLoginViewController] animated:YES completion:NULL];
        return;
    }
    
    [[VObjectManager sharedManager] answerPoll:self.sequence
                                     withAnswer:answer
                                  successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
      {
          [[VObjectManager sharedManager] pollResultsForSequence:self.sequence
                                                    successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
                                                    {
                                                        [self showResultsForAnswerId:answer.remoteId];
                                                    }
                                                       failBlock:^(NSOperation* operation, NSError* error)
                                                        {
                                                            VLog(@"Failed with error: %@", error);
                                                        }];
          
          VLog(@"Successfully answered: %@", resultObjects);
      }
                                     failBlock:^(NSOperation* operation, NSError* error)
      {
          //Error 1005 is "Poll result was already recorded.
          //If we get anything else... lie and say we already answered
          [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PollAlreadyAnswered", @"")
                                      message:error.localizedDescription
                                     delegate:nil
                            cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                            otherButtonTitles:nil] show];
          
          VLog(@"Failed to answer with error: %@", error);
      }];
}

- (void)showResultsForAnswerId:(NSNumber*)answerId
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
        
        NSInteger percentage = (result.count.doubleValue + 1.0 / totalVotes) * 100;
        percentage = percentage > 100 ? 100 : percentage;
        percentage = percentage < 0 ? 0 : percentage;
        
        label.text = [@(percentage).stringValue stringByAppendingString:@"%"];
        //unhide both flags
        if (result.answerId == answerId)
        {
            label.backgroundColor =
                    [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color"];
        }
    }
    self.firstResultLabel.hidden = self.secondResultLabel.hidden = NO;
    
    if ([answerId isEqualToNumber:self.firstAnswer.remoteId])
    {
        self.optionOneButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color"];
    }
    else if ([answerId isEqualToNumber:self.secondAnswer.remoteId])
    {
        self.optionTwoButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color"];
    }
}

- (VInboxBadgeLabel*)resultLabelForAnswerID:(NSNumber*)answerID
{
    if ([answerID isEqualToNumber:self.firstAnswer.remoteId])
        return self.firstResultLabel;
    else if ([answerID isEqualToNumber:self.secondAnswer.remoteId])
        return  self.secondResultLabel;
    
    return nil;
}

- (void)streamsWillSegue:(NSNotification *) notification
{
    [self.mpControllerOne stop];
    [self.mpControllerTwo stop];
}

@end
