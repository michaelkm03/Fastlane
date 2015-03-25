//
//  VLoadingView.m
//  victorious
//
//  Created by Michael Sena on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLoadingView.h"
#import "UIView+MotionEffects.h"

#if CGFLOAT_IS_DOUBLE
#define CEIL ceil
#else
#define CEIL ceilf
#endif

@interface VLoadingView ()

@property (nonatomic, assign) BOOL hasLayedOutPatternBackground;

@property (nonatomic, strong) UIView *interpolationView;
@property (nonatomic, strong) CALayer *replicatedLayer;
@property (nonatomic, strong) CAReplicatorLayer *xReplicatorLayer;
@property (nonatomic, strong) CAReplicatorLayer *yReplicatorLayer;

@end

@implementation VLoadingView

#pragma mark - Init

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
    self.tiledImage = [UIImage imageNamed:@"pat_geometric_01"];
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.hasLayedOutPatternBackground)
    {
        return;
    }
    
    if (self.tiledImage.size.width == 0.0f ||
        self.tiledImage.size.height == 0.0f)
    {
        return;
    }
    
    self.layer.masksToBounds = YES;
    
    NSLog(@"laying out!!!");
    
    UIView *interpolationContainer = [[UIView alloc] initWithFrame:self.bounds];
    interpolationContainer.translatesAutoresizingMaskIntoConstraints = NO;
    interpolationContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    interpolationContainer.backgroundColor = [UIColor clearColor];
    [self addSubview:interpolationContainer];
    self.interpolationView = interpolationContainer;
    
    [interpolationContainer v_addMotionEffectsWithMagnitude:-self.tiledImage.size.width];
    
    self.xReplicatorLayer = [CAReplicatorLayer layer];
    self.xReplicatorLayer.frame = CGRectMake( 0, 0, self.tiledImage.size.width, self.tiledImage.size.height);
    // Add 2 since we start with the original layer completely offscreen
    self.xReplicatorLayer.instanceCount = CEIL(CGRectGetWidth(self.bounds)/self.tiledImage.size.width) + 2;
    self.xReplicatorLayer.instanceDelay = 0.0f;
    self.xReplicatorLayer.instanceTransform = CATransform3DMakeTranslation(self.tiledImage.size.width, 0, 0);
    
    [interpolationContainer.layer addSublayer:self.xReplicatorLayer];
    
    self.yReplicatorLayer = [CAReplicatorLayer layer];
    self.yReplicatorLayer.frame = CGRectMake( 0, 0, self.tiledImage.size.width, self.tiledImage.size.height);
    // Add 2 since we start with the original layer completely offscreen
    self.yReplicatorLayer.instanceCount = CEIL(CGRectGetHeight(self.bounds)/self.tiledImage.size.height) + 2;
    self.yReplicatorLayer.instanceDelay = 0.0f;;
    self.yReplicatorLayer.instanceTransform = CATransform3DMakeTranslation(0, self.tiledImage.size.height, 0);
    
    [interpolationContainer.layer addSublayer:self.yReplicatorLayer];
    
    self.replicatedLayer = [CALayer layer];
    self.replicatedLayer.contents = (id)self.tiledImage.CGImage;
    self.replicatedLayer.frame = CGRectMake( -self.tiledImage.size.width,
                                            -self.tiledImage.size.height,
                                            self.tiledImage.size.width,
                                            self.tiledImage.size.height);
    
    [self.xReplicatorLayer addSublayer:self.replicatedLayer];
    [self.yReplicatorLayer addSublayer:self.xReplicatorLayer];
    
    self.hasLayedOutPatternBackground = YES;
    
    self.xReplicatorLayer.instanceDelay = 0.1f;
    self.yReplicatorLayer.instanceDelay = 0.1f;
    
    [self.replicatedLayer addAnimation:[self breathingAnimation] forKey:@"breathingAnimation"];
}

#pragma mark - Public

- (void)setTiledImage:(UIImage *)tiledImage
{
    _tiledImage = tiledImage;
    
    for (CALayer *layer in self.interpolationView.layer.sublayers)
    {
        [layer removeFromSuperlayer];
    }
    self.hasLayedOutPatternBackground = NO;
    [self setNeedsLayout];
}

#pragma mark - Private

- (CABasicAnimation *)breathingAnimation
{
    CABasicAnimation *breathAnimation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(opacity))];
    
    breathAnimation.autoreverses = YES;
    breathAnimation.duration = 1.2f;
    breathAnimation.fromValue = @1.0f;
    breathAnimation.toValue = @0.9f;
    breathAnimation.repeatCount = HUGE_VALF;
    breathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    return breathAnimation;
}

@end
