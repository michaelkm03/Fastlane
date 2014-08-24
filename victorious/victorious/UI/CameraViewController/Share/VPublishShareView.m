//
//  VPublishShareView.m
//  victorious
//
//  Created by Will Long on 8/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIImage+ImageCreation.h"
#import "VPublishShareView.h"
#import "VThemeManager.h"

@interface VPublishShareView()

@property (nonatomic, strong) IBOutlet UIButton* shareButton;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UIImageView* iconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation VPublishShareView

#pragma mark - Initializers

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([VPublishShareView class]) owner:self options:nil] firstObject];
    if (self)
    {
        self.defaultColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f];
        self.selectedColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    }
    return self;
}

- (id)initWithTitle:(NSString*)title image:(UIImage*)image
{
    self = [self init];
    if (self)
    {
        self.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.title = title;
    }
    return self;
}

#pragma mark - Animation

- (void)startAnimating
{
    [self continueAnimating];
}

- (void)continueAnimating
{
    if (self.selectedState != VShareViewSelectedStateLimbo) {
        return;
    }
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.backgroundImageView.transform = CGAffineTransformConcat(self.backgroundImageView.transform, CGAffineTransformMakeRotation(M_PI/3));
                     } completion:^(BOOL finished) {
                         [self continueAnimating];
                     }];
}

- (void)stopAnimating
{
    [UIView animateWithDuration:1.5f
                          delay:0.0f
         usingSpringWithDamping:0.9f
          initialSpringVelocity:1.0f
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.backgroundImageView.transform = CGAffineTransformIdentity;
                     } completion:nil];
}

#pragma mark - Property Accessors

- (void)setSelectedState:(VShareViewSelectedState)selectedState
{
    _selectedState = selectedState;
    ;    switch (selectedState)
    {
        case VShareViewSelectedStateNotSelected:
            self.shareButton.selected = NO;
            self.shareButton.enabled = YES;
            [self stopAnimating];
            break;
            
        case VShareViewSelectedStateLimbo:
            self.shareButton.selected = NO;
            self.shareButton.enabled = NO;
            [self startAnimating];
            break;

        case VShareViewSelectedStateSelected:
            self.shareButton.selected = YES;
            self.shareButton.enabled = YES;
            [self stopAnimating];
            break;
    }
    [self updateColors];
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
    
    UIImage* image = [self.shareButton backgroundImageForState:UIControlStateSelected];
    UIImage* imageWithColor = [image v_imageWithColor:selectedColor];
    [self.shareButton setBackgroundImage:imageWithColor forState:UIControlStateSelected];
    [self.shareButton setBackgroundImage:imageWithColor forState:UIControlStateSelected | UIControlStateHighlighted];
    
    [self updateColors];
}

- (void)setDefaultColor:(UIColor *)defaultColor
{
    _defaultColor = defaultColor;
    
    UIImage* image = [self.shareButton backgroundImageForState:UIControlStateNormal];
    UIImage* imageWithColor = [image v_imageWithColor:defaultColor];
    [self.shareButton setBackgroundImage:imageWithColor forState:UIControlStateNormal];
    [self.shareButton setBackgroundImage:imageWithColor forState:UIControlStateHighlighted];
    
    [self updateColors];
}

- (UIImage *)image
{
    return self.iconImageView.image;
}

- (void)setImage:(UIImage *)image
{
    self.iconImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (NSString *)title
{
    return self.titleLabel.text;
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:title ?: @"" attributes:[self attributesForTitle]];
}

- (void)updateColors
{
    UIColor* currentColor = self.shareButton.selected ? self.selectedColor : self.defaultColor;
    self.titleLabel.textColor = currentColor;
    self.iconImageView.tintColor = currentColor;
}

#pragma mark - Actions

- (IBAction)pressedShareButton:(id)sender
{
    if (self.selectionBlock)
    {
        self.selectionBlock();
    }
}

#pragma mark - Text Styling

- (NSDictionary *)attributesForTitle
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineSpacing = 0.0f;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.maximumLineHeight = 10.5f;
    return @{
        NSFontAttributeName: [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font],
        NSKernAttributeName: @(-0.5),
        NSParagraphStyleAttributeName : paragraphStyle
    };
}

@end
