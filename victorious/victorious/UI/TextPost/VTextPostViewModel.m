//
//  VTextPostViewModel.m
//  victorious
//
//  Created by Patrick Lynch on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextPostViewModel.h"
#import "VDependencyManager.h"

@interface VTextPostViewModel()

@property (nonatomic, strong) NSDictionary *textAttributes;
@property (nonatomic, strong) NSDictionary *calloutAttributes;
@property (nonatomic, strong) NSDictionary *placeholderAttributes;

@end

@implementation VTextPostViewModel

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _lineHeightMultipler   = 1.6;
        _verticalSpacing       = 2;
        _lineOffsetMultiplier  = 0.4f;
        _horizontalSpacing     = 2;
        _maxTextLength         = 200;
        _calloutWordPadding    = 10;
        _backgroundColor       = [UIColor whiteColor];
    }
    return self;
}

- (NSDictionary *)textAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    if ( _textAttributes == nil )
    {
        UIFont *font = [dependencyManager fontForKey:@"font.heading1"];
        _textAttributes = @{ NSFontAttributeName: font ?: @"",
                             NSForegroundColorAttributeName: [dependencyManager colorForKey:@"color.text.content"],
                             NSParagraphStyleAttributeName: [self paragraphStyleWithFont:font] };
    }
    return _textAttributes;
}

- (NSDictionary *)calloutAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    if ( _calloutAttributes == nil )
    {
        UIFont *font = [dependencyManager fontForKey:@"font.heading1"];
        _calloutAttributes = @{ NSFontAttributeName: font ?: @"",
                                NSForegroundColorAttributeName: [dependencyManager colorForKey:@"color.link"],
                                NSParagraphStyleAttributeName: [self paragraphStyleWithFont:font] };
    }
    return _calloutAttributes;
}

- (NSDictionary *)placeholderAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    if ( _placeholderAttributes == nil )
    {
        UIFont *font = [dependencyManager fontForKey:@"font.heading1"];
        _placeholderAttributes = @{ NSFontAttributeName: font ?: @"",
                                    NSForegroundColorAttributeName: [[dependencyManager colorForKey:@"color.text.content"] colorWithAlphaComponent:0.5f],
                                NSParagraphStyleAttributeName: [self paragraphStyleWithFont:font] };
    }
    return _placeholderAttributes;
}

- (NSParagraphStyle *)paragraphStyleWithFont:(UIFont *)font
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.hyphenationFactor = 0.5f;
    paragraphStyle.minimumLineHeight = paragraphStyle.maximumLineHeight = ((CGFloat)font.pointSize) * self.lineHeightMultipler;
    return paragraphStyle;
}

@end
