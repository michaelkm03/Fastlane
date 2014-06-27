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
    self.maxCharacterLength = self.maxCharacterLength ?: VConstantsMessageLength;

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[toolbar]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(toolbar)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(toolbar)]];
    
    UIBarButtonItem *hashtagButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cameraButtonHashTagAdd"] style:UIBarButtonItemStyleBordered target:self action:@selector(hashButtonTapped:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *countDownLabel = [[UIBarButtonItem alloc] initWithTitle:[self charactersRemainingForCharacterCount:0]
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:nil
                                                                      action:nil];
    self.hashtagButton = hashtagButton;
    self.countDownLabel = countDownLabel;
    
    toolbar.items = @[hashtagButton, flexibleSpace, countDownLabel];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setMaxCharacterLength:(NSInteger)maxCharacterLength
{
    _maxCharacterLength = maxCharacterLength;
    
    self.countDownLabel.title = [self charactersRemainingForCharacterCount:0];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, 44.0f);
}

- (void)hashButtonTapped:(UIBarButtonItem *)sender
{
    [self.textInputView replaceRange:[self.textInputView selectedTextRange] withText:@"#"];
}

- (void)startObservingTextInput:(id)textInput
{
    if ([textInput isKindOfClass:[UITextView class]])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChangeInTextView:) name:UITextViewTextDidChangeNotification object:textInput];
    }
}

- (void)stopObservingTextInput:(id)textInput
{
    if ([textInput isKindOfClass:[UITextView class]])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:textInput];
    }
}

- (NSString *)charactersRemainingForCharacterCount:(NSInteger)characterCount
{
    static NSNumberFormatter *numberFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
    {
        numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    });
    characterCount = MIN(characterCount, self.maxCharacterLength);
    return [numberFormatter stringFromNumber:@((NSInteger)self.maxCharacterLength - characterCount)];
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

#pragma mark - NSNotification handlers

- (void)textDidChangeInTextView:(NSNotification *)notification
{
    if (notification.object == self.textInputView)
    {
        NSString *text = [notification.object text];

        if (text.length > self.maxCharacterLength)
        {
            UITextPosition *beginning = self.textInputView.beginningOfDocument;
            UITextPosition *start = [self.textInputView positionFromPosition:beginning offset:self.maxCharacterLength];
            UITextPosition *end = [self.textInputView positionFromPosition:start offset:text.length - self.maxCharacterLength];
            UITextRange *textRange = [self.textInputView textRangeFromPosition:start toPosition:end];
            [self.textInputView replaceRange:textRange withText:@""];
        }
        
        self.hashtagButton.enabled = text.length < self.maxCharacterLength;
        self.countDownLabel.title = [self charactersRemainingForCharacterCount: text.length];
    }
}

@end
