//
//  VLoadingView.m
//  victorious
//
//  Created by Michael Sena on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTilePatternBackgroundView.h"
#import "UIView+MotionEffects.h"
#import "UIColor+VBrightness.h"

#if CGFLOAT_IS_DOUBLE
#define CEIL ceil
#else
#define CEIL ceilf
#endif

static NSString * const kShimmerAnimationKey = @"shimmerAnimation";

@interface VTilePatternBackgroundView ()

@property (nonatomic, assign) BOOL hasLayedOutPatternBackground;

@property (nonatomic, strong) UIView *interpolationView;
@property (nonatomic, strong) CALayer *replicatedLayer;
@property (nonatomic, strong) CAReplicatorLayer *xReplicatorLayer;
@property (nonatomic, strong) CAReplicatorLayer *yReplicatorLayer;
@property (nonatomic, strong) NSCache *renderedImageCache;

@end

@implementation VTilePatternBackgroundView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    _image = [UIImage imageNamed:@"pat_geometric"];
    _renderedImageCache = [[NSCache alloc] init];
}

#pragma mark - Property Accessors

- (void)setColor:(UIColor *)color
{
    if ([_color isEqual:color])
    {
        return;
    }
    
    _color = color;
    
    self.replicatedLayer.contents = (id)[self patternImage].CGImage;
}

- (void)setImage:(UIImage *)image
{
    if ((_image == image) || (image == nil))
    {
        return;
    }
    
    _image = image;
    
    [self.renderedImageCache removeAllObjects];
    [self layoutSubviews];
    self.replicatedLayer.contents = (id)[self patternImage].CGImage;
}

- (void)setTiltParallaxEnabled:(BOOL)tiltParallaxEnabled
{
    if (_tiltParallaxEnabled == tiltParallaxEnabled)
    {
        return;
    }
    
    _tiltParallaxEnabled = tiltParallaxEnabled;
    
    if (tiltParallaxEnabled)
    {
        [self.interpolationView v_addMotionEffectsWithMagnitude:-self.image.size.width*0.5f];
    }
    else
    {
        [self.interpolationView v_addMotionEffectsWithMagnitude:0.0f];
    }
}

- (void)setShimmerAnimationActive:(BOOL)shimmerAnimationActive
{
    if (_shimmerAnimationActive == shimmerAnimationActive)
    {
        return;
    }
    
    _shimmerAnimationActive = shimmerAnimationActive;
    
    if (shimmerAnimationActive)
    {
        [self.replicatedLayer addAnimation:[self breathingAnimation]
                                    forKey:kShimmerAnimationKey];
    }
    else
    {
        [self.replicatedLayer removeAnimationForKey:kShimmerAnimationKey];
        self.replicatedLayer.opacity = 1.0f;
    }
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.image.size.width == 0.0f ||
        self.image.size.height == 0.0f)
    {
        return;
    }
    
    if (self.hasLayedOutPatternBackground)
    {
        [self.interpolationView v_addMotionEffectsWithMagnitude:-self.image.size.width*0.5f];
        [self.replicatedLayer addAnimation:[self breathingAnimation] forKey:kShimmerAnimationKey];
        [self updateReplicantCount];
        return;
    }

    self.layer.masksToBounds = YES;
    
    UIView *interpolationContainer = [[UIView alloc] initWithFrame:self.bounds];
    interpolationContainer.translatesAutoresizingMaskIntoConstraints = NO;
    interpolationContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    interpolationContainer.backgroundColor = [UIColor clearColor];
    [self addSubview:interpolationContainer];
    self.interpolationView = interpolationContainer;
    
    [interpolationContainer v_addMotionEffectsWithMagnitude:-self.image.size.width*0.5f];
    
    self.xReplicatorLayer = [CAReplicatorLayer layer];
    self.xReplicatorLayer.frame = CGRectMake( 0, 0, self.image.size.width, self.image.size.height);
    self.xReplicatorLayer.instanceDelay = 0.0f;
    self.xReplicatorLayer.instanceTransform = CATransform3DMakeTranslation(self.image.size.width, 0, 0);
    
    [interpolationContainer.layer addSublayer:self.xReplicatorLayer];
    
    self.yReplicatorLayer = [CAReplicatorLayer layer];
    self.yReplicatorLayer.frame = CGRectMake( 0, 0, self.image.size.width, self.image.size.height);

    self.yReplicatorLayer.instanceDelay = 0.0f;
    self.yReplicatorLayer.instanceTransform = CATransform3DMakeTranslation(0, self.image.size.height, 0);
    
    [interpolationContainer.layer addSublayer:self.yReplicatorLayer];
    
    self.replicatedLayer = [CALayer layer];
    self.replicatedLayer.contents = (id)[self patternImage].CGImage;
    self.replicatedLayer.frame = CGRectMake( -self.image.size.width,
                                            -self.image.size.height,
                                            self.image.size.width,
                                            self.image.size.height);
    
    [self.xReplicatorLayer addSublayer:self.replicatedLayer];
    [self.yReplicatorLayer addSublayer:self.xReplicatorLayer];
    
    [self updateReplicantCount];
    
    self.hasLayedOutPatternBackground = YES;
    
    self.xReplicatorLayer.instanceDelay = 0.1f;
    self.yReplicatorLayer.instanceDelay = 0.1f;
    
    [self.replicatedLayer addAnimation:[self breathingAnimation] forKey:@"breathingAnimation"];
}

#pragma mark - Private

- (void)updateReplicantCount
{
    // Add 2 since we start with the original layer completely offscreen
    self.xReplicatorLayer.instanceCount = CEIL(CGRectGetWidth(self.bounds)/self.image.size.width) + 2;
    self.yReplicatorLayer.instanceCount = CEIL(CGRectGetHeight(self.bounds)/self.image.size.height) + 2;
}

- (UIImage *)patternImage
{
    UIImage *renderedImage = [self.renderedImageCache objectForKey:self.tintColor];
    
    if (renderedImage != nil)
    {
        return renderedImage;
    }
    
    if (CGColorGetAlpha(self.color.CGColor) == 0.0f)
    {
        return self.image;
    }
    
    UIColor *blendColor = [self.color colorWithAlphaComponent:0.85f];
    
    if (blendColor == nil)
    {
        return self.image;
    }
    
    UIGraphicsBeginImageContext(self.image.size);
    {
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), blendColor.CGColor);
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, self.image.size.width, self.image.size.height));
        [self.image drawInRect:CGRectMake(0, 0, self.image.size.width, self.image.size.height) blendMode:kCGBlendModeColorDodge alpha:1.0f];
        renderedImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    if (renderedImage != nil)
    {
        [self.renderedImageCache setObject:renderedImage forKey:self.tintColor];
        
        return renderedImage;
    }
    else
    {
        return self.image;
    }
}

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
