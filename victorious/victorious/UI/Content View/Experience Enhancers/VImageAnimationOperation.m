////
////  VAnimationImageView.m
////  victorious
////
////  Created by Vincent Ho on 1/26/16.
////  Copyright © 2016 Victorious. All rights reserved.
////
//
//#import "VImageAnimationOperation.h"
//
//@interface VAnimationOperation()
//
//@property (nonatomic, strong) UIImageView *animationImageView;
//@property (nonatomic, strong) NSTimer *animationTimer;
//@property (nonatomic) NSInteger frame;
//@property (nonatomic) dispatch_semaphore_t sem;
//
//@end
//
//
//@implementation VAnimationOperation
//
//- (instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super init];
//    if (self)
//    {
//        self.animationImageView = [[UIImageView alloc] initWithFrame:frame];
//        self.animationDuration = 1;
//        self.frame = -1;
////        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimating) name:ANIMATION_IMAGE_VIEW_MEMORY_WARNING_STOP object:nil];
//    }
//    return self;
//}
//
//- (void)setContentMode:(UIViewContentMode)contentMode
//{
//    _contentMode = contentMode;
//    self.animationImageView.contentMode = contentMode;
//}
//
//- (BOOL)isAnimating
//{
//    return self.frame != -1;
//}
//
//- (void)updateFrame:(id)sender
//{
//    self.frame++;
//    [self updateImageFrame];
//}
//
//- (void)updateImageFrame
//{
//    if (self.frame == (int)_animationSequence.count)
//    {
//        [self stopAnimating];
//    }
//    else if (self.frame >= 0)
//    {
//        self.animationImageView.image = self.animationSequence[self.frame];
//    }
//    else
//    {
//        self.animationImageView.image = nil;
//    }
//}
//
//- (void)startAnimatingOn:(UIView *)view
//{
//    if (self.animationSequence.count == 0)
//    {
//        [self stopAnimating];
//        return;
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [view addSubview:self.animationImageView];
//    });
//    self.frame = 0;
//    CGFloat frameDuration = self.animationDuration/self.animationSequence.count;
//    self.animationTimer = [NSTimer timerWithTimeInterval:frameDuration target:self selector:@selector(updateFrame:) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop] addTimer:self.animationTimer forMode: NSDefaultRunLoopMode];
//}
//
//- (void)startAnimatingOn:(UIView *)view withSemaphore:(dispatch_semaphore_t)sem
//{
//    _sem = sem;
//    [self startAnimatingOn:view];
//}
//
//- (void)stopAnimating
//{
//    if (self.delegate)
//    {
//        [self.delegate animation:self didFinishAnimating:(self.frame == (NSInteger)self.animationSequence.count)];
//    }
//    if (self.sem)
//    {
//        dispatch_semaphore_signal(self.sem);
//    }
//    self.frame = -1;
//    [self.animationTimer invalidate];
//    [self updateImageFrame];
//    [self.animationImageView removeFromSuperview];
//}
//
//- (void)startFlightFor:(NSTimeInterval)flightDuration on:(UIView *)view center:(CGPoint)center frame:(CGRect)frame
//{
//    self.animationImageView.center = center;
//    dispatch_async(dispatch_get_main_queue(), ^
//    {
//        [UIView animateWithDuration:flightDuration
//                              delay:0.0f
//                            options:UIViewAnimationOptionCurveLinear
//                         animations:^
//         {
//             CGFloat randomLocationX = arc4random_uniform(CGRectGetWidth(frame));
//             CGFloat randomLocationY = arc4random_uniform(CGRectGetHeight(frame));
//             self.animationImageView.center = CGPointMake(randomLocationX, randomLocationY);
//         }
//                         completion:^(BOOL finished)
//         {
//             [self startAnimatingOn:view];
//         }];
//    });
//}
//
//- (void)dealloc
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
//
//@end
