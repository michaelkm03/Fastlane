//
//  VTextField.m
//  victorious
//
//  Created by Michael Sena on 2/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextField.h"

// Theme
#import "VThemeManager.h"

// Validators
#import "VPasswordValidator.h"

// Subviews
#import "VInlineValidationView.h"

static const CGFloat kInlineValidationHeight = 20.0f;
static const CGFloat kSideInset = 10.0f;

@import AudioToolbox;

@interface VTextField ()

@property (nonatomic, strong) VInlineValidationView *inlineValidationView;

@end

@implementation VTextField

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
    self.inlineValidationView.hidden = !self.showInlineValidation;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.inlineValidationView];
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
    
    modifiedRect.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(modifiedRect);
    
    return modifiedRect;
}

#pragma mark - Public Methods

- (void)setValidator:(VStringValidator *)validator
{
    if (_validator == validator)
    {
        return;
    }
    
    if (validator)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textChanged:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:self];
    }
    
    _validator = validator;
}

- (void)incorrectTextAnimationAndVibration
{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    
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

- (void)setShowInlineValidation:(BOOL)showInlineValidation
{
    _showInlineValidation = showInlineValidation;
    [self validateTextWithValidator:self.validator];
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

#pragma mark - Notification Handlers

- (void)textChanged:(NSNotification *)notification
{
    [self validateTextWithValidator:self.validator];
}

#pragma mark - Private Methods

- (void)validateTextWithValidator:(VStringValidator *)validator
{
    NSError *validationError;
    BOOL isValid = [self.validator validateString:self.text
                                         andError:&validationError];
    self.inlineValidationView.inlineValidationText = validationError.localizedDescription;
    self.inlineValidationView.hidden = !(!isValid && self.showInlineValidation);
}

@end
