//
//  VListicleView.m
//  victorious
//
//  Created by Steven F Petteruti on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VListicleView.h"
#import "VdependencyManager.h"

static const CGFloat kRadiusOfBanner = 6.0f;
static const CGFloat kInsetForTriangle = 12.0f;
static const CGFloat kHeightOfBanner = 33.0f;
static const CGFloat kLabelInset = 10.0f;
static const CGFloat kLabelHeight = 17.0f;
static const CGFloat kMaxPercentBannerWidth = 0.58f;

@interface VListicleView ()

@property (nonatomic, strong) UILabel *listicleLabel;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VListicleView

/// Boiler plate code
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
    self.backgroundColor = [UIColor clearColor];
    [self addLabel];
}

- (void)addLabel
{
    CGRect frameLabel = CGRectMake(kLabelInset, 0, CGRectGetWidth(self.bounds) - kInsetForTriangle - (2 * kLabelInset), kLabelHeight);
    self.listicleLabel = [[UILabel alloc] initWithFrame:frameLabel];
    self.listicleLabel.center = CGPointMake(self.listicleLabel.center.x, kHeightOfBanner/2);
    self.listicleLabel.textColor = [UIColor whiteColor];
    self.listicleLabel.font = [self.dependencyManager fontForKey: VDependencyManagerLabel3FontKey];
    self.listicleLabel.layer.zPosition = 200.0f;
    [self addSubview:self.listicleLabel];
}

- (void)setHeadlineText:(NSString *)headlineText
{
    _headlineText = headlineText;
    [self updateLabelWithText:headlineText];
}

- (void)updateLabelWithText:(NSString *)text
{
    self.listicleLabel.text = text;
    
    CGSize textSize = [self.listicleLabel.text sizeWithAttributes:@{NSFontAttributeName:[self.listicleLabel font]}];
    CGFloat textWidth = MIN(textSize.width + (3 * kLabelInset), kMaxPercentBannerWidth * CGRectGetWidth(self.frame));
    CGFloat labelWidth =  MIN(textSize.width, (kMaxPercentBannerWidth * CGRectGetWidth(self.bounds)) - (3 * kLabelInset) );
    CGRect updatedLabelFrame = self.listicleLabel.frame;
    updatedLabelFrame.size = CGSizeMake(labelWidth, CGRectGetHeight(updatedLabelFrame));
    self.listicleLabel.frame = updatedLabelFrame;
    [self.listicleLabel setNeedsDisplay];
    [self drawBannerWithWidth:textWidth];
}

- (void)drawBannerWithWidth:(CGFloat)width
{
    CGPoint topRight = CGPointMake(width, 0);
    CGPoint middleRight = CGPointMake(width - kInsetForTriangle, kHeightOfBanner/2);
    CGPoint bottomRight = CGPointMake(width, kHeightOfBanner);
    CGPoint bottomLeft = CGPointMake(kRadiusOfBanner, kHeightOfBanner);
    CGPoint topLeft = CGPointMake(kRadiusOfBanner, kRadiusOfBanner);
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    [path moveToPoint:CGPointMake(0, 0)];
    
    [path addLineToPoint:topRight];
    [path addLineToPoint:middleRight];
    [path addLineToPoint:bottomRight];
    [path addLineToPoint:bottomLeft];
    [path addArcWithCenter:CGPointMake(kRadiusOfBanner, CGRectGetHeight(self.bounds)) radius:kRadiusOfBanner startAngle:[self degreesToRadians:270] endAngle:[self degreesToRadians:180]  clockwise:NO];
    [path addLineToPoint:CGPointMake(0, kRadiusOfBanner)];
    [path addArcWithCenter:topLeft radius:kRadiusOfBanner startAngle:[self degreesToRadians:180] endAngle:[self degreesToRadians:270] clockwise:YES];
    
    [path closePath];
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    [layer setPath: path.CGPath];
    [layer setFillColor:[self.dependencyManager colorForKey:VDependencyManagerAccentColorKey].CGColor];
    layer.name = @"banner";
    
    [self setSublayer:layer];
}

- (void)setSublayer:(CALayer *)sublayer
{
    NSMutableArray *mutablelayers = self.layer.sublayers.mutableCopy;
    for (CAShapeLayer *layer in [self.layer sublayers])
    {
        if ([[layer name] isEqualToString:sublayer.name])
        {
            [mutablelayers removeObject:layer];
            [mutablelayers addObject:sublayer];
        }
    }
    
    if (![mutablelayers containsObject:sublayer])
    {
        [mutablelayers addObject:sublayer];
    }

    self.layer.sublayers = mutablelayers.copy;
}

- (CGFloat)degreesToRadians:(CGFloat)degrees
{
    CGFloat radians = (M_PI * degrees) / 180.0f;
    return radians;
}

@end
