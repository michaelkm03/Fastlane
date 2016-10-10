//
//  VPlaceholderTextView.m
//  victorious
//
//  Created by Michael Sena on 12/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPlaceholderTextView.h"
#import "victorious-Swift.h"

static const CGFloat kPlaceholderAlphaNoText = 0.5f;
static const CGFloat kPlaceholderAlphaEnteringText = 0.2f;

@interface VPlaceholderTextView ()

@property (nonatomic, strong) UITextView *placeholderTextView;

@end

@implementation VPlaceholderTextView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidBeginEditingNotification
                                                  object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidEndEditingNotification
                                                  object:self];
}

- (instancetype)initWithFrame:(CGRect)frame
                textContainer:(NSTextContainer *)textContainer
{
    self = [super initWithFrame:frame
                  textContainer:textContainer];
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
    _placeholderTextView = [[UITextView alloc] initWithFrame:CGRectZero
                                               textContainer:nil];
    _placeholderTextView.userInteractionEnabled = NO;
    _placeholderTextView.backgroundColor = [UIColor clearColor];
    _placeholderTextView.alpha = kPlaceholderAlphaNoText;
    _placeholderTextView.textAlignment = self.textAlignment;
    _placeholderTextView.font = self.font;
    _placeholderTextView.textColor = self.textColor;
    
    [self addSubview:_placeholderTextView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(beganEditing:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textChanged:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(endedEditing:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:self];
    [self updatePlaceholderAttributedText];
    
    [self layoutIfNeeded];
}

#pragma mark - Property Accessors

- (void)setPlaceholderText:(NSString *)placeholderText
{
    self.placeholderTextView.text = placeholderText;
}

- (NSString *)placeholderText
{
    return self.placeholderTextView.text;
}

#pragma mark - UITextView Overrides

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    
    [self updatePlaceholderAttributedText];
    [self hidePlaceholderIfUserEnteredText];
}

- (void)setTypingAttributes:(NSDictionary *)typingAttributes
{
    [super setTypingAttributes:typingAttributes];
    
    self.placeholderTextView.attributedText = [[NSAttributedString alloc] initWithString:self.placeholderTextView.text 
                                                                              attributes:typingAttributes];
}

- (void)setLineFragmentPadding:(CGFloat)padding
{
    self.textContainer.lineFragmentPadding = padding;
    self.placeholderTextView.textContainer.lineFragmentPadding = padding;
}

- (CGFloat)lineFragmentPadding
{
    return self.textContainer.lineFragmentPadding;
}

- (void)setPlaceholderTextColor:(UIColor *)placeholderTextColor
{
    self.placeholderTextView.textColor = placeholderTextColor;
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    
    [self hidePlaceholderIfUserEnteredText];
}

- (void)setPlaceholderFont:(UIFont *)font
{
    self.placeholderTextView.font = font;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];
    
    self.placeholderTextView.textAlignment = textAlignment;
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset
{
    [super setTextContainerInset:textContainerInset];
    
    self.placeholderTextView.textContainerInset = textContainerInset;
}

- (CGFloat)calculatePlaceholderTextHeight
{
    CGFloat textHeight = CGRectGetHeight([self.placeholderText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                         attributes:@{NSFontAttributeName : self.placeholderTextView.font}
                                                                            context:nil]);
    UIEdgeInsets edgeInsets = self.v_textInsets;
    textHeight += edgeInsets.top + edgeInsets.bottom;
    
    UIEdgeInsets containerEdgeInsets = self.textContainerInset;
    textHeight += containerEdgeInsets.top + containerEdgeInsets.bottom;
    
    return textHeight;
}

- (CGFloat)contentHeight
{
    CGFloat contentSizeHeight = self.contentSize.height;
    UIEdgeInsets edgeInsets = self.v_textInsets;
    contentSizeHeight += edgeInsets.top + edgeInsets.bottom;
    
    return contentSizeHeight;
}

#pragma mark - UIView Overrides

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.placeholderTextView.frame = CGRectMake(0,
                                                0,
                                                CGRectGetWidth(self.frame),
                                                CGRectGetHeight(self.frame));
}

#pragma mark - Notification Handlers

- (void)beganEditing:(NSNotification *)notification
{
    self.placeholderTextView.alpha = (self.text.length > 0) ? 0.0f : kPlaceholderAlphaEnteringText;
}

- (void)textChanged:(NSNotification *)notificaion
{
    if (self.selectedRange.location == NSNotFound)
    {
        self.placeholderTextView.alpha = (self.text.length > 0) ? 0.0f: kPlaceholderAlphaNoText;
    }
    else
    {
        self.placeholderTextView.alpha = (self.text.length > 0) ? 0.0f: kPlaceholderAlphaEnteringText;
    }
}

- (void)endedEditing:(NSNotification *)notification
{
    [self hidePlaceholderIfUserEnteredText];
}

#pragma mark - Private Mehtods

- (void)updatePlaceholderAttributedText
{
    if (self.attributedText.string.length == 0 || self.placeholderTextView.text.length == 0)
    {
        return;
    }
    NSRangePointer range = NULL;
    NSDictionary *attrubutes = [self.attributedText attributesAtIndex:0
                                                longestEffectiveRange:range
                                                              inRange:NSMakeRange(0, self.attributedText.string.length)];
    self.placeholderTextView.attributedText = [[NSAttributedString alloc] initWithString:self.placeholderTextView.text
                                                                              attributes:attrubutes];
}

- (void)hidePlaceholderIfUserEnteredText
{
    self.placeholderTextView.alpha = (self.text.length > 0) ? 0.0f : kPlaceholderAlphaNoText;
}

@end
