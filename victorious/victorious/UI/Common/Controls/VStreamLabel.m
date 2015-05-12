//
//  VStreamLabel.m
//  victorious
//
//  Created by Michael Sena on 5/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamLabel.h"

// Views + Helpers
#import "UIView+AutoLayout.h"
#import <CCHLinkTextView/CCHLinkGestureRecognizer.h>

@interface VStreamLabel () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableDictionary *attributeForState;
@property (nonatomic, strong) UILabel *internalLabel;

@property (nonatomic, strong) CALayer *hitTestAreaLayer;

@end

@implementation VStreamLabel

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
    _attributeForState = [[NSMutableDictionary alloc] init];
    _internalLabel = [[UILabel alloc] init];
    [self addSubview:_internalLabel];
    [self v_addFitToParentConstraintsToSubview:_internalLabel];
    
    CCHLinkGestureRecognizer *gestureRecognizer = [[CCHLinkGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(recognizedGesture:)];
    gestureRecognizer.delegate = self;
    gestureRecognizer.minimumPressDuration = HUGE_VALF;
    [self addGestureRecognizer:gestureRecognizer];
    
    self.hitTestAreaLayer = [CALayer layer];
    self.hitTestAreaLayer.backgroundColor = [UIColor redColor].CGColor;
    [self.layer insertSublayer:self.hitTestAreaLayer atIndex:0];
    self.hitTestAreaLayer.hidden = _showHitTestArea ? NO : YES;
}

#pragma mark - Public

- (void)setHitInsets:(UIEdgeInsets)hitInsets
{
    _hitInsets = hitInsets;
    self.hitTestAreaLayer.frame = UIEdgeInsetsInsetRect(self.bounds, hitInsets);
}

- (void)setShowHitTestArea:(BOOL)showHitTestArea
{
    _showHitTestArea = showHitTestArea;
    self.hitTestAreaLayer.hidden = _showHitTestArea ? NO : YES;
}

- (void)setAttributedText:(NSAttributedString *)attributedText
      forStreamLabelState:(VStreamLabelState)labelState
{
    if (attributedText == nil)
    {
        [[self attributeForState] removeObjectForKey:@(labelState)];
        
    }
    else
    {
        [[self attributeForState] setObject:attributedText
                                     forKey:@(labelState)];
    }

    if (self.state == labelState)
    {
        self.internalLabel.attributedText = attributedText;
    }
}

#pragma mark - UIView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect hitArea = UIEdgeInsetsInsetRect(self.bounds, self.hitInsets);
    if (CGRectContainsPoint(hitArea, point))
    {
        return self;
    }
    return [super hitTest:point
                withEvent:event];
}

#pragma mark - Internal Methods

- (void)setState:(VStreamLabelState)state
{
    if (_state == state)
    {
        return;
    }
    
    _state = state;
    
    self.internalLabel.attributedText = [self.attributeForState objectForKey:@(state)];
}

#pragma mark - Gesture Recognizer Event

- (void)recognizedGesture:(CCHLinkGestureRecognizer *)gestureRecognizer
{
    BOOL gestureSucceeded = YES;
    switch (gestureRecognizer.result)
    {
        case CCHLinkGestureRecognizerResultTap:
        case CCHLinkGestureRecognizerResultLongPress:
        case CCHLinkGestureRecognizerResultUnknown:
            [self setState:VStreamLabelStateHighlighted];
            break;
        case CCHLinkGestureRecognizerResultFailed:
            [self setState:VStreamLabelStateDefault];
            gestureSucceeded = NO;
            break;
    }
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateEnded:
            [self setState:VStreamLabelStateDefault];
            if (gestureSucceeded)
            {
                [self.delegate selectedStreamLabel:self];
            }
            break;
        default:
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end

@implementation VStreamLabel (UILabelForwarding)

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    self.internalLabel.textAlignment = textAlignment;
}

- (NSTextAlignment)textAlignment
{
    return self.internalLabel.textAlignment;
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    self.internalLabel.lineBreakMode = lineBreakMode;
}

- (NSLineBreakMode)lineBreakMode
{
    return self.internalLabel.lineBreakMode;
}

@end
