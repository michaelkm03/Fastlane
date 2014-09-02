//
//  VPollAnswerBarViewController.m
//  victorious
//
//  Created by Will Long on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPollAnswerBarViewController.h"

#import "VConstants.h"

#import "VAnalyticsRecorder.h"
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

@property (weak, nonatomic) IBOutlet UIView* selectedContainmentView;
@property (weak, nonatomic) IBOutlet UIView* selectedAnswerView;
@property (weak, nonatomic) IBOutlet UIImageView* selectedHexImage;
@property (weak, nonatomic) IBOutlet UIImageView* selectedCheckImage;

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
    UIImage* newImage = [self.selectedHexImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.selectedHexImage setImage:newImage];
    self.selectedHexImage.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    self.selectedAnswerView.translatesAutoresizingMaskIntoConstraints = YES;
    self.selectedCheckImage.translatesAutoresizingMaskIntoConstraints = YES;
    self.selectedHexImage.translatesAutoresizingMaskIntoConstraints = YES;
    self.selectedContainmentView.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.leftLabel.attributedText = [[NSAttributedString alloc] initWithString:[[self.answers firstObject] label] attributes:[self attributesForAnswerLabel]];
    self.rightLabel.attributedText = [[NSAttributedString alloc] initWithString:[[self.answers lastObject] label] attributes:[self attributesForAnswerLabel]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[VObjectManager sharedManager] pollResultsForSequence:self.sequence
                                              successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
     {
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
    self.leftLabel.attributedText = [[NSAttributedString alloc] initWithString:[[self.answers firstObject] label] attributes:[self attributesForAnswerLabel]];
    self.rightLabel.attributedText = [[NSAttributedString alloc] initWithString:[[self.answers lastObject] label] attributes:[self attributesForAnswerLabel]];
    
    self.orImageView.hidden = YES;
    
    self.selectedContainmentView.hidden = YES;
}

- (NSDictionary *)attributesForAnswerLabel
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.minimumLineHeight = 17.0f;
    paragraphStyle.maximumLineHeight = 17.0f;
    
    return @{ NSParagraphStyleAttributeName: paragraphStyle };
}

- (void)checkIfAnswered
{
    self.leftButton.userInteractionEnabled = YES;
    self.rightButton.userInteractionEnabled = YES;
    
    for (VPollResult* result in [VObjectManager sharedManager].mainUser.pollResults)
    {
        if ([result.sequenceId isEqualToNumber: self.sequence.remoteId])
        {
            [self.delegate answeredPollWithAnswerId:result.answerId];
            
            [self answerAnimationForAnswerID:result.answerId];
            
            self.leftButton.userInteractionEnabled = NO;
            self.rightButton.userInteractionEnabled = NO;
            
            return;
        }
    }
}

- (void)answerAnimationForAnswerID:(NSNumber*)answerID
{
    CGRect emptyFrame   = CGRectInset(self.selectedContainmentView.frame, 0, 0);
    CGRect fullFrame    = CGRectInset(self.selectedContainmentView.frame, 0, 0);
    
    CGRect initialHexFrame      = CGRectInset(self.selectedHexImage.frame, 0, 0);
    CGRect finalHexFrame        = CGRectInset(self.selectedHexImage.frame, 0, 0);
    
    CGRect initialAnswerFrame   = CGRectInset(self.selectedAnswerView.frame, 0, 0);
    CGRect finalAnswerFrame     = CGRectInset(self.selectedAnswerView.frame, 0, 0);
    
    if ([answerID isEqualToNumber:((VAnswer*)[self.answers firstObject]).remoteId])
    {
        emptyFrame.origin.x = self.orImageView.frame.origin.x + self.orImageView.frame.size.width;
        emptyFrame.size.width = 0;
        
        fullFrame.origin.x = 0;
        fullFrame.size.width = self.orImageView.frame.origin.x + self.orImageView.frame.size.width;
        
        initialHexFrame.origin.x = -self.orImageView.frame.size.width;
        finalHexFrame.origin.x = self.orImageView.frame.origin.x;
        
        initialAnswerFrame.origin.x = -fullFrame.size.width;
        finalAnswerFrame.origin.x = 0;
    }
    else
    {
        emptyFrame.origin.x = self.orImageView.frame.origin.x;
        emptyFrame.size.width = 0;
        
        fullFrame.origin.x = self.orImageView.frame.origin.x;
        fullFrame.size.width = self.orImageView.frame.origin.x + self.orImageView.frame.size.width;
        
        initialHexFrame.origin.x = 0;
        finalHexFrame.origin.x = 0;
        
        initialAnswerFrame.origin.x = self.selectedHexImage.frame.size.width / 2;
        finalAnswerFrame.origin.x = self.selectedHexImage.frame.size.width / 2;
    }
    
    self.selectedContainmentView.frame = emptyFrame;
    self.selectedHexImage.frame = initialHexFrame;
    self.selectedCheckImage.frame = initialHexFrame;
    self.selectedAnswerView.frame = initialAnswerFrame;
    
    self.selectedContainmentView.hidden = NO;
    
    [UIView animateWithDuration:.5f
                     animations:^
     {
         self.selectedContainmentView.frame = fullFrame;
         self.selectedHexImage.frame = finalHexFrame;
         self.selectedCheckImage.frame = finalHexFrame;
         self.selectedAnswerView.frame = finalAnswerFrame;
     }];
}

#pragma mark - Button actions
-(IBAction)pressedAnswerButton:(id)sender
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    self.leftButton.userInteractionEnabled = NO;
    self.rightButton.userInteractionEnabled = NO;
    
    VAnswer* chosenAnswer;
    
    NSInteger tag = ((UIButton*)sender).tag;
    if ((NSUInteger)tag >= [self.answers count])
    {
        chosenAnswer = [self.answers lastObject];
    }
    else
    {
        chosenAnswer = (self.answers)[tag];
    }
    
    [self answerPollWithAnswer:chosenAnswer];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryInteraction action:@"Answered Poll" label:self.sequence.name value:nil];
}

- (void)answerPollWithAnswer:(VAnswer*)answer
{
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        
        [[VObjectManager sharedManager] pollResultsForSequence:self.sequence
                                                  successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
         {
             [self.delegate answeredPollWithAnswerId:answer.remoteId];
             [self answerAnimationForAnswerID:answer.remoteId];
         }
                                                     failBlock:^(NSOperation* operation, NSError* error)
         {
             VLog(@"Failed with error: %@", error);
         }];
    };
    
    [[VObjectManager sharedManager] answerPoll:self.sequence
                                     withAnswer:answer
                                  successBlock:success
                                     failBlock:^(NSOperation* operation, NSError* error)
      {
          //Error 1005 is "Poll result was already recorded.
          //If we get anything else... lie and say we already answered
          if ([error.domain isEqualToString:kVictoriousErrorDomain])
          {
              [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PollAlreadyAnswered", @"")
                                          message:error.localizedDescription
                                         delegate:nil
                                cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                otherButtonTitles:nil] show];
          }
          else
          {
              //This is a solution to a bad UX experience. A user will answer a poll and get a non-victorious error, and fail for no reason.  They'll continue to attempt to answer, but server will start responding with real "Poll already answered" errors, and get stuck in that flow until they leave and return to the poll.
              success(nil, nil, nil);
          }

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
