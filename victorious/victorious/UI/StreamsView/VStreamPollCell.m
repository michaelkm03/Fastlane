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

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    NSArray* answers = [[self.sequence firstNode] firstAnswers];

    self.optionOneButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.optionTwoButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.optionOneButton.tintColor = [UIColor whiteColor];
    self.optionTwoButton.tintColor = [UIColor whiteColor];

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
    
    [self setupOrLabel];
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
- (IBAction)pressedOptionOne:(id)sender
{
    [self answerPollWithAnswer:_firstAnswer];
    self.optionOneButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.stream.text"];
}

- (IBAction)pressedOptionTwo:(id)sender
{
    [self answerPollWithAnswer:_secondAnswer];
    self.optionTwoButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.stream.text"];
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
    for( VPollResult* result in self.sequence.pollResults)
    {
        //unhide both flags
        if (result.answerId == answer.remoteId && [result objectID])
        {
            VUser* mainUser = [VObjectManager sharedManager].mainUser;
            VPollResult* resultInContext = (VPollResult*)[mainUser.managedObjectContext objectWithID:[result objectID]];
            [mainUser addPollResultsObject:resultInContext];
            [mainUser.managedObjectContext save:nil];
            //count++ in case it didn't populate the database in time
            //Color the flag since it was your answer
        }
        //else show it normally
    }
}
@end
