//
//  VTrimControl.m
//  victorious
//
//  Created by Michael Sena on 12/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrimControl.h"

static const CGFloat kTrimHeadHeight = 44.0f;
static const CGFloat kTrimHeadWidth = 88.0f;
static const CGFloat kTrimBodyWidth = 5.0f;

@interface VTrimControl ()

@property (nonatomic, strong) UIView *trimThumbHead;
@property (nonatomic, strong) UIView *trimThumbBody;

@property (nonatomic, strong) UIPanGestureRecognizer *headGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *bodyGestureRecognizer;

@end

static inline CGFloat TrimHeadYCenter()
{
    return 2 + kTrimHeadHeight * 0.5f;
}

@implementation VTrimControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    self.trimThumbHead = [[UIView alloc] initWithFrame:CGRectMake(0, 2, kTrimHeadWidth, kTrimHeadHeight)];
    self.trimThumbHead.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.trimThumbHead];
    self.headGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(pannedHead:)];
    [self.trimThumbHead addGestureRecognizer:self.headGestureRecognizer];
    
    self.trimThumbBody = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.trimThumbHead.frame) - 0.5f * kTrimBodyWidth,
                                                                CGRectGetMaxY(self.trimThumbHead.frame),
                                                                kTrimBodyWidth,
                                                                CGRectGetMaxY(self.bounds) - CGRectGetMaxY(self.trimThumbHead.frame))];
    self.trimThumbBody.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.trimThumbBody];
    self.bodyGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(pannedBody:)];
    [self.trimThumbBody addGestureRecognizer:self.bodyGestureRecognizer];
}

#pragma mark - Gesture Recognizer

- (void)pannedHead:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self];
    CGPoint newCenter = CGPointMake(kTrimHeadWidth * 0.5f, TrimHeadYCenter());
    if (location.x < kTrimHeadWidth * 0.5f)
    {
        
    }
}

- (void)pannedBody:(UIPanGestureRecognizer *)gestureRecognizer
{
    
}

@end
