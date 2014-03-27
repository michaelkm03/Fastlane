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
#import "VObjectManager+Login.h"

#import "VLoginViewController.h"
#import "VObjectManager+Sequence.h"

#import "VThemeManager.h"

@interface VPollAnswerBarViewController ()

@property (strong) UIDynamicAnimator* animator;

@end

@implementation VPollAnswerBarViewController

+ (instancetype)sharedInstance
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkIfAnswered)
                                                 name:kPollResultsLoaded
                                               object:nil];
    [self checkIfAnswered];
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    [self checkIfAnswered];
}

- (void)checkIfAnswered
{
    for (VPollResult* result in [VObjectManager sharedManager].mainUser.pollResults)
    {
        if ([result.sequenceId isEqualToNumber: self.sequence.remoteId])
        {
            __block NSNumber* answerId = result.answerId;
            [[VObjectManager sharedManager] pollResultsForSequence:self.sequence
                                                      successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
             {
                 [self.delegate answeredPollWithAnswerId:answerId];
             }
                                                         failBlock:^(NSOperation* operation, NSError* error)
             {
                 VLog(@"Failed with error: %@", error);
             }];
            return;
        }
    }
    
    self.answers = [[self.sequence firstNode] firstAnswers];
    self.leftLabel.text = ((VAnswer*)[self.answers firstObject]).label;
    self.rightLabel.text = ((VAnswer*)[self.answers lastObject]).label;
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
    chosenAnswer = (self.answers)[tag];
    
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
                                                        [self.delegate answeredPollWithAnswerId:answer.remoteId];
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

- (UIButton*)buttonForAnswerID:(NSNumber*)answerID
{
    if ([answerID isEqualToNumber:((VAnswer*)[self.answers firstObject]).remoteId])
        return self.leftButton;
    
    else if ([answerID isEqualToNumber:((VAnswer*)[self.answers lastObject]).remoteId])
        return  self.rightButton;

    return nil;
}

@end
