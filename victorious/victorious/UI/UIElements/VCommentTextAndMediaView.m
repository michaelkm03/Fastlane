//
//  VCommentTextAndMediaView.m
//  victorious
//
//  Created by Josh Hinman on 8/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCommentTextAndMediaView.h"
#import "VThemeManager.h"

#ifdef __LP64__
#define CEIL(a) ceil(a)
#else
#define CEIL(a) ceilf(a)
#endif

@interface VCommentTextAndMediaView ()

@property (nonatomic, weak) UILabel *textLabel;

@end

@implementation VCommentTextAndMediaView

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
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.numberOfLines = 0;
    [self addSubview:textLabel];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textLabel]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(textLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[textLabel]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(textLabel)]];
    self.textLabel = textLabel;
}

#pragma mark - Properties

- (void)setText:(NSString *)text
{
    _text = [text copy];
    self.textLabel.attributedText = [[NSAttributedString alloc] initWithString:(text ?: @"") attributes:[[self class] attributesForText]];
}

#pragma mark -

+ (NSDictionary *)attributesForText
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.minimumLineHeight = 20.0f;
    paragraphStyle.maximumLineHeight = 20.0f;
    
    return @{ NSFontAttributeName: [UIFont systemFontOfSize:17.0f],
              NSForegroundColorAttributeName: [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryLinkColor],
              NSParagraphStyleAttributeName: paragraphStyle,
           };
}

+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width text:(NSString *)text
{
    if (!text)
    {
        return 0;
    }
    
    CGRect boundingRect = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:[self attributesForText]
                                             context:[[NSStringDrawingContext alloc] init]];
    return CEIL(CGRectGetHeight(boundingRect));
}

@end
