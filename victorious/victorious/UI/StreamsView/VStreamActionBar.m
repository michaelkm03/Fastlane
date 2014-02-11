//
//  VStreamActionBar.m
//  victorious
//
//  Created by Will Long on 2/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamActionBar.h"

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAnswer.h"


NSInteger const VStreamActionBarHeight = 150;

@interface VStreamActionBar()

@property (weak, nonatomic) IBOutlet UIView* pollView;
@property (weak, nonatomic) IBOutlet UIView* quizView;
@property (weak, nonatomic) IBOutlet UIView* throwView;

@property (weak, nonatomic) IBOutlet UIButton* firstPollButton;
@property (weak, nonatomic) IBOutlet UIButton* secondPollButton;

@property (weak, nonatomic) IBOutlet UIButton* firstQuizButton;
@property (weak, nonatomic) IBOutlet UIButton* secondQuizButton;
@property (weak, nonatomic) IBOutlet UIButton* thirdQuizButton;
@property (weak, nonatomic) IBOutlet UIButton* fourthQuizButton;

@property (strong, nonatomic) NSArray* answers;

@end

@implementation VStreamActionBar

+ (instancetype)viewFromNib
{
    Class class = [self class];
    NSString *nibName = NSStringFromClass(class);
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    VStreamActionBar *view = [nibViews objectAtIndex:0];
    return view;
}

- (void)setCurrentSequence:(VSequence *)currentSequence
{
    _currentSequence = currentSequence;
    
    self.answers = [[currentSequence firstNode] firstAnswers];
    
    if ([currentSequence isPoll])
    {
        self.pollView.hidden = NO;
        self.quizView.hidden = YES;
        self.throwView.hidden = YES;
        
        self.firstPollButton.titleLabel.text = ((VAnswer*)[self.answers objectAtIndex:0]).label;
        self.secondPollButton.titleLabel.text = ((VAnswer*)[self.answers objectAtIndex:1]).label;
    }
    else if ([currentSequence isQuiz])
    {
        self.throwView.hidden = NO;
        self.quizView.hidden = YES;
        self.pollView.hidden = YES;
        
        self.firstQuizButton.titleLabel.text = ((VAnswer*)[self.answers objectAtIndex:0]).label;
        self.secondQuizButton.titleLabel.text = ((VAnswer*)[self.answers objectAtIndex:1]).label;
        self.thirdQuizButton.titleLabel.text = ((VAnswer*)[self.answers objectAtIndex:3]).label;
        self.fourthQuizButton.titleLabel.text = ((VAnswer*)[self.answers objectAtIndex:4]).label;
    }
    else
    {
        self.throwView.hidden = NO;
        self.quizView.hidden = YES;
        self.pollView.hidden = YES;
    }
}

- (IBAction)pressedAnswer:(id)sender
{
    NSInteger buttonID = ((UIView*)sender).tag;
    
    if (buttonID > [self.answers count])
        //Something bad happened, just ignore it
        return;
    
    [self.delegate finishedPollOrQuizWithAnswer:[self.answers objectAtIndex:buttonID]];
}

- (IBAction)presedTomatoButton:(id)sender
{
    [self.delegate throwTomato];
}

- (IBAction)pressedKissButton:(id)sender
{
    [self.delegate blowKiss];
}

@end
