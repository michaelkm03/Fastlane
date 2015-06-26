//
//  VContentLikeButton.m
//  victorious
//
//  Created by Patrick Lynch on 6/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VContentLikeButton.h"
#import "VLargeNumberFormatter.h"

static const CGFloat kMargin = 10.0f;
static const CGFloat kBackgroundAlpha = 0.5f;
static const UIEdgeInsets kTitleInsets = (UIEdgeInsets){ 0, 8, 0, 0 };
static const UIEdgeInsets kImageEdgeInsets = (UIEdgeInsets){ 0, -6, 0, 0 };
static const CGFloat kLabelFontSize = 14.0f;
static const CGFloat kCornerRadius = 4.0f;

@interface VContentLikeButton()

@property (nonatomic, strong) UIImage *unselectedImage;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) VLargeNumberFormatter *numberFormatter;

@end

@implementation VContentLikeButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self != nil )
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if ( self != nil )
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.unselectedImage = [[UIImage imageNamed:@"like"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.selectedImage = [[UIImage imageNamed:@"like_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:kBackgroundAlpha];
    [self setTitleEdgeInsets:kTitleInsets];
    [self setImageEdgeInsets:kImageEdgeInsets];
    [self.titleLabel setFont:[UIFont systemFontOfSize:kLabelFontSize]];
    self.tintColor = [UIColor whiteColor];
    self.layer.cornerRadius = kCornerRadius;
    
    [self setActive:NO];
}

- (void)didMoveToSuperview
{
    if ( self.superview != nil )
    {
        [self addSizeConstraints];
        [self setTitle:@"0" forState:UIControlStateNormal];
    }
}

- (void)addSizeConstraints
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = @{ @"button" : self };
    NSDictionary *metrics = @{ @"width" : @(kMargin + CGRectGetWidth(self.imageView.bounds) + kMargin),
                               @"height" : @(kMargin + CGRectGetHeight(self.imageView.bounds) + kMargin) };
    self.widthConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(width)]" options:kNilOptions metrics:metrics views:views].firstObject;
    self.heightConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[button(height)]" options:kNilOptions metrics:metrics views:views].firstObject;
    [self addConstraint:self.widthConstraint];
    [self addConstraint:self.heightConstraint];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    
    NSDictionary *attributes = @{ NSFontAttributeName : self.titleLabel.font };
    CGSize textSize = [title sizeWithAttributes:attributes];
    
    self.widthConstraint.constant = kMargin + CGRectGetWidth(self.imageView.bounds) + self.titleEdgeInsets.left + textSize.width + kMargin;
    self.heightConstraint.constant = kMargin + CGRectGetHeight(self.imageView.bounds) + kMargin;
    
    [self layoutIfNeeded];
}

- (VLargeNumberFormatter *)numberFormatter
{
    if ( _numberFormatter == nil )
    {
        _numberFormatter = [[VLargeNumberFormatter alloc] init];
    }
    return _numberFormatter;
}

- (void)setActive:(BOOL)active
{
    UIImage *image = active ? self.selectedImage : self.unselectedImage;
    [self setImage:image forState:UIControlStateNormal];
}

- (void)setCount:(NSUInteger)count
{
    [self setTitle:[self.numberFormatter stringForInteger:count] forState:UIControlStateNormal];
}

@end
