//
//  VTextPostViewModel.m
//  victorious
//
//  Created by Patrick Lynch on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextPostViewModel.h"
#import "VDependencyManager.h"

static NSString * const kFontNameKey = @"font.heading2";
static NSString * const kNormalTextFontColor = @"color.text.content";
static NSString * const kCalloutTextFontColor = @"color.link";

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
        _calloutWordKerning    = 10.0f;
        _backgroundColor       = [UIColor whiteColor];
    }
    return self;
}

- (NSDictionary *)textAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    if ( _textAttributes == nil )
    {
        UIFont *font = [dependencyManager fontForKey:kFontNameKey];
        _textAttributes = @{ NSFontAttributeName: font ?: @"",
                             NSForegroundColorAttributeName: [dependencyManager colorForKey:kNormalTextFontColor],
                             NSParagraphStyleAttributeName: [self paragraphStyleWithFont:font] };
    }
    return _textAttributes;
}

- (NSDictionary *)calloutAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    if ( _calloutAttributes == nil )
    {
        UIFont *font = [dependencyManager fontForKey:kFontNameKey];
        _calloutAttributes = @{ NSFontAttributeName: font ?: @"",
                                NSForegroundColorAttributeName: [dependencyManager colorForKey:kCalloutTextFontColor],
                                NSParagraphStyleAttributeName: [self paragraphStyleWithFont:font] };
    }
    return _calloutAttributes;
}

- (NSParagraphStyle *)paragraphStyleWithFont:(UIFont *)font
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.minimumLineHeight = paragraphStyle.maximumLineHeight = ((CGFloat)font.pointSize) * self.lineHeightMultipler;
    return paragraphStyle;
}

@end
