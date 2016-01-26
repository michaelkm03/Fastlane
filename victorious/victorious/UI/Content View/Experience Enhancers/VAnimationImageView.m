//
//  VAnimationImageView.m
//  victorious
//
//  Created by Vincent Ho on 1/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import "VAnimationImageView.h"

@interface VAnimationImageView()

@property (nonatomic, strong) UIImageView * animationImageView;
@property (nonatomic, strong) NSTimer * animationTimer;
@property (nonatomic) NSInteger frame;
@property (nonatomic) dispatch_semaphore_t sem;

@end


@implementation VAnimationImageView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        _animationImageView = [[UIImageView alloc] initWithFrame:frame];
        _animationDuration = 1;
        _frame = -1;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimating) name:ANIMATION_IMAGE_VIEW_MEMORY_WARNING_STOP object:nil];
    }
    return self;
}

-(void)setContentMode:(UIViewContentMode)contentMode {
    _contentMode = contentMode;
    _animationImageView.contentMode = contentMode;
}

-(BOOL)isAnimating {
    return _frame != -1;
}

-(void)updateFrame:(id)sender {
    _frame++;
    [self updateImageFrame];
}

-(void)updateImageFrame {
    if (_frame == (int)_animationSequence.count) {
        [self stopAnimating];
    }
    else if (_frame >= 0) {
        _animationImageView.image = _animationSequence[_frame];
    }
    else {
        _animationImageView.image = nil;
    }
}

-(void)startAnimatingOn:(UIView *)view {
//    NSAssert(self.animationSequence.count > 0, @"Must have an animation sequence");
    if (self.animationSequence.count == 0) {
        [self stopAnimating];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [view addSubview:_animationImageView];
    });
    _frame = 0;
    CGFloat frameDuration = _animationDuration/self.animationSequence.count;
    _animationTimer = [NSTimer timerWithTimeInterval:frameDuration target:self selector:@selector(updateFrame:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_animationTimer forMode: NSDefaultRunLoopMode];
}

-(void)startAnimatingOn:(UIView *)view withSemaphore:(dispatch_semaphore_t)sem {
    _sem = sem;
    [self startAnimatingOn:view];
}

-(void)stopAnimating {
    if (self.delegate)
        [self.delegate animation:self didFinishAnimating:(_frame == (int)_animationSequence.count)];
    if (_sem)
        dispatch_semaphore_signal(_sem);
    _frame = -1;
    [_animationTimer invalidate];
    [self updateImageFrame];
    [_animationImageView removeFromSuperview];
}

-(void)startFlightFor:(NSTimeInterval)flightDuration on:(UIView *)view center:(CGPoint)center frame:(CGRect)frame {
    _animationImageView.center = center;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:flightDuration
                              delay:0.0f
                            options:UIViewAnimationOptionCurveLinear
                         animations:^
         {
             CGFloat randomLocationX = arc4random_uniform(CGRectGetWidth(frame));
             CGFloat randomLocationY = arc4random_uniform(CGRectGetHeight(frame));
             _animationImageView.center = CGPointMake(randomLocationX, randomLocationY);
         }
                         completion:^(BOOL finished)
         {
             [self startAnimatingOn:view];
         }];
    });
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
