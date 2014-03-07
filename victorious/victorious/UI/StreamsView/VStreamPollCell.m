//
//  VStreamPollCell.m
//  victoriOS
//
//  Created by Will Long on 12/19/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VStreamPollCell.h"

#import "VObjectManager+Sequence.h"

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAnswer.h"
#import "VAsset.h"
#import "VPollResult.h"
#import "VUser.h"

#import "NSString+VParseHelp.h"

static NSString* kOrIconImage = @"orIconImage";

@import MediaPlayer;

@interface VStreamPollCell ()
@property (nonatomic, weak) VAnswer* firstAnswer;
@property (nonatomic, weak) VAnswer* secondAnswer;

@property (nonatomic, copy) NSString* firstAssetUrl;
@property (nonatomic, copy) NSString* secondAssetUrl;

@property (nonatomic) BOOL animating;
@end

@implementation VStreamPollCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
 
    NSMutableArray* animationImages = [[NSMutableArray alloc] initWithCapacity:40];
    for (int i = 1; i < 40; i++)
    {
        if ( i > 9 && i < 35)
        {
            [animationImages addObject:[UIImage imageNamed:[kOrIconImage stringByAppendingString:@"10-34"]]];
        }
        else
        {
            [animationImages addObject:[UIImage imageNamed:[kOrIconImage stringByAppendingString:@(i).stringValue]]];
        }
    }
    [animationImages addObject:[UIImage imageNamed:[kOrIconImage stringByAppendingString:@(1).stringValue]]];
    
    self.animationImage.animationImages = animationImages;
    self.animationImage.animationDuration = 1.2f;
    self.animationImage.animationRepeatCount = 1;
}
- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    NSArray* answers = [[self.sequence firstNode] firstAnswers];
    self.firstAnswer = [answers firstObject];
    if ([answers count] >= 2)
    {
        self.secondAnswer = answers[1];
    }
    
    [self setupMedia];
    [self checkIfAnswered];
}

- (void)setupMedia
{
    VAsset* firstAsset = [[self.sequence firstNode] firstAsset];
    if (firstAsset)
    {
        self.firstAssetUrl = firstAsset.data;
    }
    else
    {
        self.firstAssetUrl = self.firstAnswer.mediaUrl;
        self.secondAssetUrl = self.secondAnswer.mediaUrl;
    }
    
    if ([[self.firstAssetUrl pathExtension] isEqualToString:VConstantMediaExtensionM3U8])
    {
        [self.previewImageView setImageWithURL:[NSURL URLWithString:[self.firstAssetUrl previewImageURLForM3U8]]];
    }
    else
    {
        [self.previewImageView setImageWithURL:[NSURL URLWithString:self.firstAssetUrl]];
    }
    
    if ([[self.secondAssetUrl pathExtension] isEqualToString:VConstantMediaExtensionM3U8])
    {
        [self.previewImageTwo setImageWithURL:[NSURL URLWithString:[self.secondAssetUrl previewImageURLForM3U8]]];
    }
    else
    {
        [self.previewImageTwo setImageWithURL:[NSURL URLWithString:self.secondAssetUrl]];
    }
}

- (void)checkIfAnswered
{
    for (VPollResult* result in [VObjectManager sharedManager].mainUser.pollResults)
    {
        if ([result.sequenceId isEqualToNumber: self.sequence.remoteId])
        {
//            [self showResultsForAnswerId:result.answerId];
        }
    }
}

- (void)firstAnimation
{
    if (self.animating)
    {
        [self.animationImage startAnimating];
        [self performSelector:@selector(firstAnimation) withObject:nil afterDelay:5.0f];
    }
}
//- (void)answerPollWithAnswer:(VAnswer*)answer
//{
//    if(![VObjectManager sharedManager].mainUser)
//    {
//        [self.parentTableViewController presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
//        return;
//    }
//    
//    [[VObjectManager sharedManager] answerPoll:self.sequence
//                                     withAnswer:answer
//                                  successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
//      {
//          [[VObjectManager sharedManager] pollResultsForSequence:self.sequence
//                                                    successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
//                                                    {
//                                                        [self showResultsForAnswerId:answer.remoteId];
//                                                    }
//                                                       failBlock:^(NSOperation* operation, NSError* error)
//                                                        {
//                                                            VLog(@"Failed with error: %@", error);
//                                                        }];
//          
//          VLog(@"Successfully answered: %@", resultObjects);
//      }
//                                     failBlock:^(NSOperation* operation, NSError* error)
//      {
//          //Error 1005 is "Poll result was already recorded.
//          //If we get anything else... lie and say we already answered
//          [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PollAlreadyAnswered", @"")
//                                      message:error.localizedDescription
//                                     delegate:nil
//                            cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
//                            otherButtonTitles:nil] show];
//          
//          VLog(@"Failed to answer with error: %@", error);
//      }];
//}
//
//- (void)showResultsForAnswerId:(NSNumber*)answerId
//{
//    NSInteger totalVotes = 0;
//    for( VPollResult* result in self.sequence.pollResults)
//    {
//        totalVotes+= result.count.integerValue;
//    }
//    totalVotes = totalVotes ? totalVotes : 1; //dividing by 0 is bad.
//    
//    for( VPollResult* result in self.sequence.pollResults)
//    {
//        VBadgeLabel* label = [self resultLabelForAnswerID:result.answerId];
//        
//        NSInteger percentage = (result.count.doubleValue + 1.0 / totalVotes) * 100;
//        percentage = percentage > 100 ? 100 : percentage;
//        percentage = percentage < 0 ? 0 : percentage;
//        
//        label.text = [@(percentage).stringValue stringByAppendingString:@"%"];
//        //unhide both flags
//        if (result.answerId == answerId)
//        {
//            label.backgroundColor =
//                    [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color"];
//        }
//    }
//    self.firstResultLabel.hidden = self.secondResultLabel.hidden = NO;
//    
//    if ([answerId isEqualToNumber:self.firstAnswer.remoteId])
//    {
//        self.optionOneButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color"];
//    }
//    else if ([answerId isEqualToNumber:self.secondAnswer.remoteId])
//    {
//        self.optionTwoButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color"];
//    }
//}
//
//- (VBadgeLabel*)resultLabelForAnswerID:(NSNumber*)answerID
//{
//    if ([answerID isEqualToNumber:self.firstAnswer.remoteId])
//        return self.firstResultLabel;
//    else if ([answerID isEqualToNumber:self.secondAnswer.remoteId])
//        return  self.secondResultLabel;
//    
//    return nil;
//}

@end
