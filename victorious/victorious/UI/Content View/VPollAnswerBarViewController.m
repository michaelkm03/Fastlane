//
//  VPollAnswerBarViewController.m
//  victorious
//
//  Created by Will Long on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPollAnswerBarViewController.h"

#import "UIView+VFrameManipulation.h"
#import "VConstants.h"

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAnswer.h"
#import "VPollResult.h"
#import "VUser.h"

#import "VLoginViewController.h"
#import "VObjectManager+Sequence.h"

@interface VPollAnswerBarViewController ()

@property (weak, nonatomic) IBOutlet UIButton* leftButton;
@property (weak, nonatomic) IBOutlet UIButton* rightButton;
@property (weak, nonatomic) IBOutlet UILabel* leftLabel;
@property (weak, nonatomic) IBOutlet UILabel* rightLabel;

@property (weak, nonatomic) IBOutlet UIView* backgroundView;
@property (weak, nonatomic) IBOutlet UIView* shadeView;

@property (strong) UIDynamicAnimator* animator;

@end

@implementation VPollAnswerBarViewController

+ (VPollAnswerBarViewController *)sharedInstance
{
    static  VPollAnswerBarViewController*   sharedInstance;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        sharedInstance = (VPollAnswerBarViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kPollAnswerBarStoryboardID];
    });
    
    return sharedInstance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sequence = self.sequence;//force a load
    self.leftLabel.textAlignment = NSTextAlignmentCenter;
    self.rightLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    [self checkIfAnswered];
}

- (void)checkIfAnswered
{
    for (VPollResult* result in [VObjectManager sharedManager].mainUser.pollResults)
    {
        if ([result.sequenceId isEqualToNumber: self.sequence.remoteId])
        {
            [self showResultsForAnswerId:result.answerId];
            return;
        }
    }
    
    self.answers = [[self.sequence firstNode] firstAnswers];
    self.leftLabel.text = ((VAnswer*)[self.answers firstObject]).label;
    self.rightLabel.text = ((VAnswer*)[self.answers lastObject]).label;
}

#pragma mark - Animation
- (void)animateInWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion
{
    [self.backgroundView setXOrigin:self.view.frame.size.width];
    [self.shadeView setXOrigin:self.view.frame.size.width];
    
    self.rightButton.alpha = 0;
    self.leftButton.alpha = 0;
    self.rightLabel.alpha = 0;
    self.leftLabel.alpha = 0;
    
    [UIView animateWithDuration:duration/2
                     animations:^
                     {
                         [self.backgroundView setXOrigin:0];
                         [self.shadeView setXOrigin:self.view.frame.size.width - self.shadeView.frame.size.width];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:duration/2
                                          animations:^
                                          {
                                              self.rightButton.alpha = 1;
                                              self.leftButton.alpha = 1;
                                              self.rightLabel.alpha = 1;
                                              self.leftLabel.alpha = 1;
                                          }
                                          completion:completion];
                     }];
}



- (void)animateOutWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:duration/2
                     animations:^
                     {
                         self.rightButton.alpha = 0;
                         self.leftButton.alpha = 0;
                         self.rightLabel.alpha = 0;
                         self.leftLabel.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:duration/2
                                          animations:^
                                          {
                                              [self.backgroundView setXOrigin:self.view.frame.size.width];
                                              [self.shadeView setXOrigin:self.view.frame.size.width];
                                          }
                                          completion:completion];
                     }];
}

#pragma mark - Button actions
-(IBAction)pressedAnswerButton:(id)sender
{
    VAnswer* chosenAnswer;
    
    NSInteger tag = ((UIButton*)sender).tag;
    if (tag >= [self.answers count])
    {
        chosenAnswer = [self.answers lastObject];
    }
    chosenAnswer = [self.answers objectAtIndex:tag];
    
    [self answerPollWithAnswer:chosenAnswer];
}

- (void)answerPollWithAnswer:(VAnswer*)answer
{
    if(![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }

    [[VObjectManager sharedManager] answerPoll:self.sequence
                                     withAnswer:answer
                                  successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
      {
          [[VObjectManager sharedManager] pollResultsForSequence:self.sequence
                                                    successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
                                                    {
//                                                        [self showResultsForAnswerId:answer.remoteId];
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
//        VBadgeLabel* label = [self resultLabelForAnswerID:result.answerId];

        NSInteger percentage = (result.count.doubleValue + 1.0 / totalVotes) * 100;
        percentage = percentage > 100 ? 100 : percentage;
        percentage = percentage < 0 ? 0 : percentage;

//        label.text = [@(percentage).stringValue stringByAppendingString:@"%"];
        //unhide both flags
        if (result.answerId == answerId)
        {
//            label.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color"];
        }
    }
//    self.firstResultLabel.hidden = self.secondResultLabel.hidden = NO;
//    if ([answerId isEqualToNumber:self.firstAnswer.remoteId])
//    {
//        self.optionOneButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color"];
//    }
//    else if ([answerId isEqualToNumber:self.secondAnswer.remoteId])
//    {
//        self.optionTwoButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color"];
//    }
}

- (UIButton*)buttonForAnswerID:(NSNumber*)answerID
{
    if ([answerID isEqualToNumber:((VAnswer*)[self.answers firstObject]).remoteId])
        return self.leftButton;
    
    else if ([answerID isEqualToNumber:((VAnswer*)[self.answers lastObject]).remoteId])
        return  self.rightButton;

    return nil;
}

@end
