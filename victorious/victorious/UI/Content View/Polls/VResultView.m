//
//  VResultView.m
//  victorious
//
//  Created by Will Long on 3/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VResultView.h"
#import "UIView+AutoLayout.h"
#import "VThemeManager.h"

@interface VResultView ()

@property (nonatomic) CGFloat progress;
@property (strong, nonatomic) UIImageView *resultArrow;
@property (strong, nonatomic) UILabel *resultLabel;
@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *bottomConstraint;

@end

@implementation VResultView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIImage *arrowImage = [UIImage imageNamed:@"ResultArrowVertical"];
        UIEdgeInsets edgeInsets;
        edgeInsets.left = 0.0f;
        edgeInsets.top = 10.0f;
        edgeInsets.right = 0.0f;
        edgeInsets.bottom = 0.0f;
        arrowImage = [arrowImage resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeTile];
        _resultArrow = [[UIImageView alloc] initWithImage:[arrowImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [self addSubview:_resultArrow];
        [self v_addPinToLeadingTrailingToSubview:_resultArrow];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_resultArrow
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0 constant:0.0f]];
        self.heightConstraint = [NSLayoutConstraint constraintWithItem:_resultArrow
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0 constant:self.bounds.size.height];
        [self addConstraint:self.heightConstraint];
        
        
        _resultLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _resultLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
        _resultLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
        _resultLabel.textAlignment = NSTextAlignmentCenter;
        _resultLabel.minimumScaleFactor = 0.5f;
        _resultLabel.adjustsFontSizeToFitWidth = YES;
        _resultLabel.minimumScaleFactor = 0.75f;
        [self addSubview:_resultLabel];
        NSDictionary *views = @{ @"arrow" : _resultArrow, @"label" : _resultLabel };
        NSDictionary *metrics = @{ @"vspace" : @(-40), @"height" : @(30.0f) };
        _resultLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label(height)]-vspace-[arrow]"
                                                                     options:kNilOptions
                                                                     metrics:metrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[label]|"
                                                                     options:kNilOptions
                                                                     metrics:metrics
                                                                       views:views]];
        
        _progress = -1.0f;
        [self updateHeight];
        
        [self layoutSubviews];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateHeight];
}

- (void)updateHeight
{
    if ( self.progress >= 0.0f )
    {
        self.heightConstraint.constant = 35.0 + self.bounds.size.height * self.progress;
    }
    else
    {
        self.heightConstraint.constant = 0.0f;
    }
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    self.resultArrow.tintColor = color;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    void (^animations)() = ^
    {
        self.progress = progress;
    };
    if ( animated )
    {
        [UIView animateWithDuration:0.75f
                              delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.0f
                            options:kNilOptions
                         animations:animations
                         completion:nil];
    }
    else
    {
        animations();
    }
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    [self updateHeight];
    [self layoutIfNeeded];
    
    static NSNumberFormatter *percentFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        percentFormatter = [[NSNumberFormatter alloc] init];
        [percentFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    });
    self.resultLabel.text = [percentFormatter stringFromNumber:@(progress)];
}

@end
