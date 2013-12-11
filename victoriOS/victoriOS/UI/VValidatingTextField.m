//
//  VValidatingTextField.m
//  victoriOS
//
//  Created by Gary Philipp on 12/10/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VValidatingTextField.h"

NSString*   const       kNameRegularExpressionString        =   @"[a-zA-Z]{2,}+(\\s{1}[a-zA-Z]{2,}+)+";
NSString*   const       kEmailRegularExpressionString       =   @"";
NSString*   const       kPhoneNumberRegularExpressionString =   @"\\d{3}-\\d{3}-\\d{3}";

@interface      VValidatingTextField    ()
@property (readonly) BOOL canValid;
@property UIColor *baseColor;
@property BOOL fieldHasBeenEdited;
@end

@implementation VValidatingTextField
{
    ValidationResult    _validationResult;
    NSString*           _previousText;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    {
        [self configureForValidation];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self configureForValidation];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self configureForValidation];
    }
    return self;
}

- (void)configureForValidation
{
    _minimalNumberOfCharactersToStartValidation = 1;
    _validWhenTyping = YES;
    _fieldHasBeenEdited = NO;
    _validationResult = kValidationFailed;
    [self setRegexpPattern:@""];
}

- (BOOL)isEditing
{
    BOOL isEditing = [super isEditing];
    if ((isEditing && _validWhenTyping) || (!isEditing && !_validWhenTyping))
    {
        if (!_previousText || ![_previousText isEqualToString:self.text])
        {
            _previousText = self.text;
            if (self.text.length > 0 && !_fieldHasBeenEdited)
                _fieldHasBeenEdited = YES;

            if (_fieldHasBeenEdited)
            {
                [self willChangeValueForKey:@"isValid"];
                _validationResult = [self validRegexp];
                [self didChangeValueForKey:@"isValid"];

                if (self.text.length >= _minimalNumberOfCharactersToStartValidation)
                {
                    [self updateViewForState:_validationResult];

                    if (_validatedFieldBlock)
                        _validatedFieldBlock(_validationResult, isEditing);
                }
                else if (self.text.length == 0 || self.text.length < _minimalNumberOfCharactersToStartValidation)
                {
                    if (_baseColor)
                        self.textColor = _baseColor;

                    if (_validatedFieldBlock)
                        _validatedFieldBlock(kValueTooShortToValidate, isEditing);
                }
            }
        }
    }

    return isEditing;
}

//#pragma mark -

- (BOOL)isValid
{
    return (kValidationPassed == _validationResult);
}

- (void)setMinimalNumberOfCharactersToStartValidation:(NSUInteger)minimalNumberOfCharacterToStartValidation
{
    if (minimalNumberOfCharacterToStartValidation  < 1)
        minimalNumberOfCharacterToStartValidation = 1;
    _minimalNumberOfCharactersToStartValidation = minimalNumberOfCharacterToStartValidation;
}

#pragma mark - 

- (void)setRegexpPattern:(NSString *)regexpPattern
{
    if (!regexpPattern)
        regexpPattern = @"";
    
    [self configureRegexpWithPattern:regexpPattern];
}

- (NSString *)regexpPattern
{
    return _regexp.pattern;
}

- (void)configureRegexpWithPattern:(NSString *)pattern
{
    _regexp = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
}

#pragma mark -

- (void)setRegexpInvalidColor:(UIColor *)regexpInvalidColor
{
    if (!_baseColor)
        _baseColor = self.textColor;
    _invalidColor = regexpInvalidColor;
}

- (void)setRegexpValidColor:(UIColor *)regexpValidColor
{
    if (!_baseColor)
        _baseColor = self.textColor;
    _validColor = regexpValidColor;
}

#pragma mark -

- (void)updateViewForState:(ValidationResult)result
{
    UIImageView *imageView = (UIImageView *)self.rightView;
    
    BOOL canShow = self.canValid;
    imageView.hidden = !canShow;
    
    if (canShow)
    {
        UIColor *color = self.textColor;
        if (result == kValidationPassed && _validColor)
            color = _validColor;
        else if (result == kValidationFailed && _invalidColor)
            color = _invalidColor;
        
        self.textColor = color;
    }
}

- (BOOL)canValid
{
    return _regexp.pattern != nil;
}

#pragma mark -

- (ValidationResult)validRegexp
{
    NSString *text = self.text;
    ValidationResult valid = kValidationPassed;

    if (self.canValid)
    {
        NSRange textRange = NSMakeRange(0, text.length);
        NSArray *matches = [_regexp matchesInString:text options:0 range:textRange];
        
        NSRange resultRange = NSMakeRange(NSNotFound, 0);
        if (matches.count == 1)
        {
            NSTextCheckingResult *result = (NSTextCheckingResult *)matches[0];
            resultRange = result.range;
        }
        else if (matches.count != 0)
        {
            resultRange = [self rangeFromTextCheckingResults:matches];
        }
        
        if (NSEqualRanges(textRange, resultRange))
            valid = kValidationPassed;
        else
            valid = kValidationFailed;
    }

    return valid;
}

- (NSRange)rangeFromTextCheckingResults:(NSArray *)array
{
    // Valid first match
    NSTextCheckingResult *firstResult = (NSTextCheckingResult *)array[0];
    if (!(firstResult.range.location == 0 && firstResult.range.length > 0))
        return NSMakeRange(NSNotFound, 0);
    
    
    // Valid all matches
    NSInteger lastLocation = 0;
    
    if (array.count > 0)
    {
        for (NSTextCheckingResult *result in array)
        {
            if (lastLocation == result.range.location)
                lastLocation = result.range.location + result.range.length;
             else
                break;
        }
    }
    
    return NSMakeRange(0, lastLocation);
}

@end
