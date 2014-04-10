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

@property (weak, nonatomic) IBOutlet UIView* answeredView;
@property (weak, nonatomic) IBOutlet UIView* selectedAnswerView;
@property (weak, nonatomic) IBOutlet UIImageView* answeredHexImage;
@property (weak, nonatomic) IBOutlet UIImageView* answeredCheckImage;

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
    
    self.selectedAnswerView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    UIImage* newImage = [self.answeredHexImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.answeredHexImage setImage:newImage];
    self.answeredHexImage.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    
    self.leftLabel.text = ((VAnswer*)[self.answers firstObject]).label;
    self.rightLabel.text = ((VAnswer*)[self.answers lastObject]).label;
    
    [[VObjectManager sharedManager] pollResultsForSequence:self.sequence
                                              successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
     {
         VLog(@"Succeeded with objects: %@", resultObjects);
         [self checkIfAnswered];
     }
                                                 failBlock:^(NSOperation* operation, NSError* error)
     {
         VLog(@"Failed with error: %@", error);
     }];
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    self.answers = [[self.sequence firstNode] firstAnswers];
    self.leftLabel.text = ((VAnswer*)[self.answers firstObject]).label;
    self.rightLabel.text = ((VAnswer*)[self.answers lastObject]).label;
    
    self.orImageView.hidden = YES;
}

- (void)checkIfAnswered
{
    for (VPollResult* result in [VObjectManager sharedManager].mainUser.pollResults)
    {
        if ([result.sequenceId isEqualToNumber: self.sequence.remoteId])
        {
            [self.delegate answeredPollWithAnswerId:result.answerId];
            
            [self answerAnimationForAnswerID:result.answerId];
            
            return;
        }
    }
}

- (void)answerAnimationForAnswerID:(NSNumber*)answerID
{
    CGRect emptyFrame;
    CGRect fullFrame;
    CGFloat hexXOffset, selectedAnswerXOffset;
    
    self.selectedAnswerView.hidden = NO;
    
    CGFloat fullWidth = self.selectedAnswerView.frame.size.width + self.answeredHexImage.frame.size.width / 2;
    
    if ([answerID isEqualToNumber:((VAnswer*)[self.answers firstObject]).remoteId])
    {
        CGFloat emptyXOrigin = self.orImageView.frame.origin.x + self.orImageView.frame.size.width;
        emptyFrame = CGRectMake(emptyXOrigin, 0, 0, self.view.frame.size.height);
        fullFrame = CGRectMake(0, 0, fullWidth, self.view.frame.size.height);
        
        [self.answeredHexImage setXOrigin:-self.answeredHexImage.frame.size.width];
        [self.selectedAnswerView setXOrigin: -fullWidth];
        [self.answeredHexImage setXOrigin:self.orImageView.frame.origin.x];
        [self.selectedAnswerView setXOrigin:0];
        selectedAnswerXOffset = 0;
        hexXOffset = self.orImageView.frame.origin.x;
    }
    else
    {
        emptyFrame = CGRectMake(self.orImageView.frame.origin.x, 0, 0, self.view.frame.size.height);
        fullFrame = CGRectMake(self.orImageView.frame.origin.x, 0, fullWidth, self.view.frame.size.height);
        
        [self.answeredHexImage setXOrigin:0];
        [self.selectedAnswerView setXOrigin:self.answeredHexImage.center.x];
        selectedAnswerXOffset = self.answeredHexImage.center.x;
        hexXOffset = 0;
    }
    self.answeredView.frame = emptyFrame;
    self.answeredView.hidden = NO;
    
    [UIView animateWithDuration:1.0f
                     animations:^
     {
         self.answeredView.frame = fullFrame;
         [self.answeredHexImage setXOrigin:hexXOffset];
         [self.selectedAnswerView setXOrigin:selectedAnswerXOffset];
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
    else
    {
        chosenAnswer = (self.answers)[tag];
    }
    
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
