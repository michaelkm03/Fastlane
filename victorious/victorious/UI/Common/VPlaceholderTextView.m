//
//  VPlaceholderTextView.m
//  victorious
//
//  Created by Michael Sena on 12/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPlaceholderTextView.h"

@interface VPlaceholderTextView ()

@property (nonatomic, strong) UITextView *placeholderTextView;

@end


@implementation VPlaceholderTextView

- (instancetype)initWithFrame:(CGRect)frame
                textContainer:(NSTextContainer *)textContainer
{
    self = [super initWithFrame:frame
                  textContainer:textContainer];
    if (self)
    {
        _placeholderTextView = [[UITextView alloc] initWithFrame:frame
                                                   textContainer:nil];
        _placeholderTextView.userInteractionEnabled = NO;
        [self addSubview:_placeholderTextView];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[placeholderTextView]|"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:@{@"placeholderTextView":_placeholderTextView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[placeholderTextView]|"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:@{@"placeholderTextView":_placeholderTextView}]];
    }
    return self;
}

#pragma mark - Property Accessors

- (void)setPlaceholderAttributedText:(NSAttributedString *)placeholderAttributedText
{
    self.placeholderTextView.attributedText = placeholderAttributedText;
}

- (NSAttributedString *)placeholderAttributedText
{
    return self.placeholderTextView.attributedText;
}



@end
