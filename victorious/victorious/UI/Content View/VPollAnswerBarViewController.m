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

@interface VPollAnswerBarViewController ()

@property (weak, nonatomic) IBOutlet UIButton* leftButton;
@property (weak, nonatomic) IBOutlet UIButton* rightButton;

@property (weak, nonatomic) IBOutlet UIView* backgroundView;
@property (weak, nonatomic) IBOutlet UIView* shadeView;

@property (strong, nonatomic) NSArray* answers;

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
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    self.answers = [[sequence firstNode] firstAnswers];
    [self.leftButton setTitle:((VAnswer*)[self.answers firstObject]).label forState:UIControlStateNormal];
    [self.rightButton setTitle:((VAnswer*)[self.answers lastObject]).label forState:UIControlStateNormal];
}

#pragma mark - Animation
- (void)animateInWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion
{
    [self.backgroundView setXOrigin:self.view.frame.size.width];
    [self.shadeView setXOrigin:self.view.frame.size.width];
    
    self.rightButton.alpha = 0;
    self.leftButton.alpha = 0;
    
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
-(IBAction)pressedLeftButton:(id)sender
{
    
}

-(IBAction)pressedRightButton:(id)sender
{
    
}
@end
