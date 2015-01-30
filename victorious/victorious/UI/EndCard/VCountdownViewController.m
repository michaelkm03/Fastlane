//
//  VCountdownViewController.m
//  AutoplayNext
//
//  Created by Patrick Lynch on 1/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCountdownView.h"
#import "VCountdownViewController.h"

@interface VCountdownViewController ()

@property (nonatomic, readonly) VCountdownView *countdownView;
@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UILabel *label;

@end

@implementation VCountdownViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.alpha = 0.0f;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( self.label == nil )
    {
        self.label = [[UILabel alloc] initWithFrame:self.view.bounds];
        self.label.textColor = [UIColor whiteColor];
        self.label.font = [UIFont boldSystemFontOfSize:18.0f];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.layer.shadowColor = [UIColor blackColor].CGColor;
        self.label.layer.shadowOpacity = 1.0f;
        self.label.layer.shadowRadius = 3.0f;
        self.label.layer.shadowOffset = CGSizeMake( 0, 1 );
        [self.view addSubview:self.label];
    }
}

- (void)dealloc
{
    [self.timer invalidate];
}

- (VCountdownView *)countdownView
{
    return (VCountdownView *)self.view;
}

- (void)startTimerWithDuration:(NSTimeInterval)duration
{
    self.duration = duration;
    self.currentTime = duration;
    [self.countdownView startCountdownWithTime:duration];
    [self updateLabel];
    
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                  target:self
                                                selector:@selector(updateTimer:)
                                                userInfo:nil
                                                 repeats:YES];
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^void
     {
         self.view.alpha = 1.0f;
     } completion:nil];
}

- (void)updateLabel
{
    NSUInteger displayTime = ceil( self.currentTime );
    if ( displayTime > 0 )
    {
        self.label.text = [NSString stringWithFormat:@"%lu", (unsigned long)displayTime];
    }
    else
    {
        self.label.text = nil;
    }
}

- (void)stopTimer
{
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^void
     {
         self.view.alpha = 0.0f;
     }
                     completion:^(BOOL finished)
     {
         [self.timer invalidate];
         self.currentTime = 0.0f;
         self.label.text = nil;
     }];
}

- (void)updateTimer:(id)sender
{
    self.currentTime --;
    
    [self updateLabel];
    
    if ( self.currentTime <= 0.0f )
    {
        if ( self.delegate != nil )
        {
            [self.delegate countDownComplete];
        }
        [self stopTimer];
    }
}

@end
