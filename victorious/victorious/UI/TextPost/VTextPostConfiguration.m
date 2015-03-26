//
//  VTextPostConfiguration.m
//  victorious
//
//  Created by Patrick Lynch on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextPostConfiguration.h"
#import "VDependencyManager.h"

@implementation VTextPostConfiguration

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _lineHeightMultipler   = 1.6;
        _verticalSpacing       = 2;
        _lineOffsetMultiplier  = 0.4f;
        _horizontalSpacing     = 3;
        _maxTextLength         = 200;
        _backgroundColor       = [UIColor whiteColor];
    }
    return self;
}

- (NSDictionary *)textAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIFont *font = [dependencyManager fontForKey:@"font.heading1"];
    return @{ NSFontAttributeName: font ?: @"",
              NSForegroundColorAttributeName: [dependencyManager colorForKey:@"color.text.content"],
              NSParagraphStyleAttributeName: [self paragraphStyleWithFont:font] };
}

- (NSDictionary *)hashtagTextAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIFont *font = [dependencyManager fontForKey:@"font.heading1"];
    return @{ NSFontAttributeName: font ?: @"",
              NSForegroundColorAttributeName: [dependencyManager colorForKey:@"color.link"],
              NSParagraphStyleAttributeName: [self paragraphStyleWithFont:font] };
}

- (NSParagraphStyle *)paragraphStyleWithFont:(UIFont *)font
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft; //f das fsdNSTextAlignmentCenter;
    paragraphStyle.minimumLineHeight = paragraphStyle.maximumLineHeight = ((CGFloat)font.pointSize) * self.lineHeightMultipler;
    return paragraphStyle;
}

@end
