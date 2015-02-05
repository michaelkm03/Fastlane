//
//  VInlineValidationView.m
//  victorious
//
//  Created by Michael Sena on 2/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInlineValidationView.h"
#import "VThemeManager.h"

@interface VInlineValidationView ()

@property (nonatomic, strong) UIImageView *alertImageView;
@property (nonatomic, strong) UILabel *inlineValidaitonLabel;

@end

@implementation VInlineValidationView

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
    self.alertImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.alertImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.alertImageView.image = [[UIImage imageNamed:@"inline_validation_alert_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.alertImageView.tintColor = [UIColor redColor];
    [self addSubview:self.alertImageView];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView(14)]|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:@{@"imageView": self.alertImageView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[imageView(14)]"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:@{@"imageView": self.alertImageView}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.alertImageView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.alertImageView
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    
    self.inlineValidaitonLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.inlineValidaitonLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.inlineValidaitonLabel.textAlignment = NSTextAlignmentLeft;
    self.inlineValidaitonLabel.text = @"Invalid email";
    self.inlineValidaitonLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel4Font];
    self.inlineValidaitonLabel.textColor = [UIColor redColor];
    [self addSubview:self.inlineValidaitonLabel];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[imageView]-5-[label]|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:@{@"imageView":self.alertImageView,
                                                                           @"label":self.inlineValidaitonLabel}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.inlineValidaitonLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.alertImageView
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
}

- (void)setInlineValidationText:(NSString *)inlineValidationText
{
    self.inlineValidaitonLabel.text = inlineValidationText;
}

- (NSString *)inlineValidationText
{
    return self.inlineValidaitonLabel.text;
}

@end
