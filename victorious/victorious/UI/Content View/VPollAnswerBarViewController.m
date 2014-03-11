//
//  VPollAnswerBarViewController.m
//  victorious
//
//  Created by Will Long on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPollAnswerBarViewController.h"

#import "UIView+VFrameManipulation.h"

@interface VPollAnswerBarViewController ()

@property (weak, nonatomic) IBOutlet UIButton* positiveEmotiveButton;
@property (weak, nonatomic) IBOutlet UIButton* negativeEmotiveButton;

@property (weak, nonatomic) IBOutlet UIView* backgroundView;
@property (weak, nonatomic) IBOutlet UIView* shadeView;

@end

@implementation VPollAnswerBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Animation
- (void)animateInWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion
{
    [self.backgroundView setXOrigin:self.view.frame.size.width];
    [self.shadeView setXOrigin:self.view.frame.size.width];
    
    self.negativeEmotiveButton.alpha = 0;
    self.positiveEmotiveButton.alpha = 0;
    
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
                                              self.negativeEmotiveButton.alpha = 1;
                                              self.positiveEmotiveButton.alpha = 1;
                                          }
                                          completion:completion];
                     }];
}

- (void)animateOutWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:duration/2
                     animations:^
                     {
                         self.negativeEmotiveButton.alpha = 0;
                         self.positiveEmotiveButton.alpha = 0;
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

@end
