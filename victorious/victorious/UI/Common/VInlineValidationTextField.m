//
//  VInlineValidationTextField.m
//  victorious
//
//  Created by Michael Sena on 2/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInlineValidationTextField.h"

// Theme
#import "VThemeManager.h"

// Validators
#import "VPasswordValidator.h"

// Subviews
#import "VInlineValidationView.h"

static const CGFloat kInlineValidationHeight = 20.0f;
static const CGFloat kSideInset = 10.0f;
static const CGFloat kBottomClearInset = 2.0f;

@import AudioToolbox;

@interface VInlineValidationTextField ()

@property (nonatomic, strong) VInlineValidationView *inlineValidationView;

@property (nonatomic, strong) NSAttributedString *oldPlaceholder;

@property (nonatomic, strong) CALayer *bottomBorder;
@property (nonatomic, readwrite) BOOL hasResignedFirstResponder;

@end

@implementation VInlineValidationTextField

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:self];
}

#pragma mark - Initializers

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
    CGRect inlineValidationFrame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds), kInlineValidationHeight);
    self.inlineValidationView = [[VInlineValidationView alloc] initWithFrame:inlineValidationFrame];
    self.inlineValidationView.hidden = YES;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.inlineValidationView];
}

#pragma mark -  Property Accessors

- (void)setInactivePlaceholder:(NSAttributedString *)inactivePlaceholder
{
    _inactivePlaceholder = inactivePlaceholder;
    
    [self updateForFirstResponder];
}

- (void)setActivePlaceholder:(NSAttributedString *)activePlaceholder
{
    _activePlaceholder = activePlaceholder;
    
    [self updateForFirstResponder];
}

- (void)updateForFirstResponder
{
    if ([self isFirstResponder])
    {
        self.attributedPlaceholder = self.activePlaceholder;
    }
    else
    {
        self.attributedPlaceholder = self.inactivePlaceholder;
    }
}

#pragma mark - UIResponder

- (BOOL)becomeFirstResponder
{
    self.attributedPlaceholder = self.activePlaceholder;
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    self.attributedPlaceholder = self.inactivePlaceholder;
    if (self.isFirstResponder)
    {
        self.hasResignedFirstResponder = YES;
    }

    return [super resignFirstResponder];
}

#pragma mark - UITextField

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect modifiedRect = [super textRectForBounds:bounds];
    
    modifiedRect = CGRectInset(modifiedRect, kSideInset, 0.0f);
    modifiedRect.origin.y = kInlineValidationHeight;
    modifiedRect.size.height -= kInlineValidationHeight;
    
    return modifiedRect;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
    CGRect modifiedRect = [super clearButtonRectForBounds:bounds];
    
    modifiedRect.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(modifiedRect) - kBottomClearInset;
    
    return modifiedRect;
}

#pragma mark - Public Methods

- (void)hideInvalidText
{
    self.inlineValidationView.hidden = YES;
}

- (void)showInvalidText:(NSString *)invalidText
               animated:(BOOL)animated
                  shake:(BOOL)shake
                 forced:(BOOL)force
{
    if (!force && !self.hasResignedFirstResponder)
    {
        return;
    }
    
    self.inlineValidationView.inlineValidationText = invalidText;
    self.inlineValidationView.hidden = NO;
    
    if (animated)
    {
        [self showIncorrectTextAnimationAndVibration];
    }
    
    if (shake)
    {
        [self playVibration];
    }
}

- (void)playVibration
{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

- (void)showIncorrectTextAnimationAndVibration
{
    [UIView animateKeyframesWithDuration:0.35f
                                   delay:0.0f
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^
     {
         [UIView addKeyframeWithRelativeStartTime:0.0f
                                 relativeDuration:0.3f
                                       animations:^
          {
              self.layer.affineTransform = CGAffineTransformMakeTranslation(-5.0f, 0.0f);
          }];
         [UIView addKeyframeWithRelativeStartTime:0.3f
                                 relativeDuration:0.3f
                                       animations:^
          {
              self.layer.affineTransform = CGAffineTransformMakeTranslation(5.0f, 0.0f);
          }];
         [UIView addKeyframeWithRelativeStartTime:0.6f
                                 relativeDuration:0.3f
                                       animations:^
          {
              self.layer.affineTransform = CGAffineTransformMakeTranslation(0.0f, 0.0f);
          }];
     }
                              completion:nil];
    
}

- (void)applyTextFieldStyle:(VTextFieldStyle)textFieldStyle
{
    switch (textFieldStyle)
    {
        case VTextFieldStyleLoginRegistration:
            self.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
            self.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
            self.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
            break;
        default:
            break;
    }
}

- (void)clearValidation
{
    self.hasResignedFirstResponder = NO;
    self.inlineValidationView.hidden = YES;
}

@end
