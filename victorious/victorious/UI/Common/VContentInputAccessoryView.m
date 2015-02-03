//
//  VContentInputAccessoryView.m
//  victorious
//
//  Created by Josh Hinman on 5/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConstants.h"
#import "VContentInputAccessoryView.h"

@interface VContentInputAccessoryView ()

@property (nonatomic, weak) UIBarButtonItem *countDownLabel;

@end

@implementation VContentInputAccessoryView

#pragma mark - NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Initializers

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    toolbar.backgroundColor = [UIColor whiteColor];
    [self addSubview:toolbar];

    //Default to the standard message length if no length is provided
    _maxCharacterLength = VConstantsMessageLength;

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[toolbar]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(toolbar)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(toolbar)]];
    
    UIBarButtonItem *hashtagButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cameraButtonHashTagAdd"] style:UIBarButtonItemStylePlain target:self action:@selector(hashButtonTapped:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *countDownLabel = [[UIBarButtonItem alloc] initWithTitle:[self charactersRemainingStringForCharacterCount:0]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:nil
                                                                      action:nil];
    self.hashtagButton = hashtagButton;
    self.countDownLabel = countDownLabel;
    
    toolbar.items = @[hashtagButton, flexibleSpace, countDownLabel];
}

#pragma mark - UIView

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, 44.0f);
}

#pragma mark - Target/Action

- (void)hashButtonTapped:(UIBarButtonItem *)sender
{
    if ([self.delegate respondsToSelector:@selector(hashTagButtonTappedOnInputAccessoryView:)])
    {
        [self.delegate hashTagButtonTappedOnInputAccessoryView:self];
    }

    if (![self shouldAddHashTags])
    {
        return;
    }
    
    [self.textInputView replaceRange:[self.textInputView selectedTextRange] withText:@"#"];
}

#pragma mark - Properties

- (void)setTextInputView:(id<UITextInput>)textInputView
{
    if (_textInputView)
    {
        [self stopObservingTextInput:_textInputView];
    }
    if (textInputView)
    {
        [self startObservingTextInput:textInputView];
    }
    _textInputView = textInputView;
}

- (void)setHashtagButton:(UIBarButtonItem *)hashtagButton
{
    _hashtagButton = hashtagButton;
}

- (void)setMaxCharacterLength:(NSUInteger)maxCharacterLength
{
    _maxCharacterLength = maxCharacterLength;
    
    self.countDownLabel.title = [self charactersRemainingStringForCharacterCount:0];
}

#pragma mark - NSNotification
#pragma mark Handlers

- (void)textDidChangeInTextView:(NSNotification *)notification
{
    if (notification.object != self.textInputView)
    {
        return;
    }
 
    // Update our own state
    NSString *text = [notification.object text];
    self.hashtagButton.enabled = ((text.length < self.maxCharacterLength) && ([self shouldAddHashTags]));
    self.countDownLabel.title = [self charactersRemainingStringForCharacterCount: text.length];
    
    // Limit text input to maxCharacterLength
    if ([self.delegate respondsToSelector:@selector(shouldLimitTextEntryForInputAccessoryView:)])
    {
        if (![self.delegate shouldLimitTextEntryForInputAccessoryView:self])
        {
            return;
        }
    }
    if (text.length > self.maxCharacterLength)
    {
        UITextPosition *beginning = self.textInputView.beginningOfDocument;
        UITextPosition *start = [self.textInputView positionFromPosition:beginning offset:(NSInteger)self.maxCharacterLength];
        UITextPosition *end = [self.textInputView positionFromPosition:start offset:(NSInteger)(text.length - self.maxCharacterLength)];
        UITextRange *textRange = [self.textInputView textRangeFromPosition:start toPosition:end];
        [self.textInputView replaceRange:textRange withText:@""];
    }
}

#pragma mark Notification Observation

- (void)startObservingTextInput:(id)textInput
{
    if ([textInput isKindOfClass:[UITextView class]])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChangeInTextView:) name:UITextViewTextDidChangeNotification object:textInput];
    }
    
    if ([textInput isKindOfClass:[UITextField class]])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChangeInTextView:) name:UITextFieldTextDidChangeNotification object:textInput];
    }
}

- (void)stopObservingTextInput:(id)textInput
{
    if ([textInput isKindOfClass:[UITextView class]])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:textInput];
    }
}

#pragma mark - Internal Methods

- (BOOL)shouldAddHashTags
{
    if ([self.delegate respondsToSelector:@selector(shouldAddHashTagsForInputAccessoryView:)])
    {
        return [self.delegate shouldAddHashTagsForInputAccessoryView:self];
    }
    return YES;
}

- (NSString *)charactersRemainingStringForCharacterCount:(NSUInteger)characterCount
{
    static NSNumberFormatter *numberFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      numberFormatter = [[NSNumberFormatter alloc] init];
                      numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
                  });
    characterCount = MIN(characterCount, self.maxCharacterLength);
    return [numberFormatter stringFromNumber:@(self.maxCharacterLength - characterCount)];
}

@end
