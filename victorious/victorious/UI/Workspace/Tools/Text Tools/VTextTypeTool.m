//
//  VTextTypeTool.m
//  victorious
//
//  Created by Michael Sena on 12/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTextTypeTool.h"
#import "VDependencyManager.h"

// Keys for fonts
NSString * const kParagraphFontKey = @"font.paragraph";

// Keys for colors
NSString * const kMainTextColorKey = @"color.text";

static NSString * const kTitleKey = @"title";
static NSString * const kTextToolHorizontalAlignment = @"horizontalAlignment";
static NSString * const kTextToolVerticalAlignment = @"verticalAlignment";
static NSString * const kTextToolStrokeColor = @"strokeColor";
static NSString * const kTextToolStrokeWidth = @"strokeWidth";
static NSString * const kTextToolPlaceholderText = @"placeholderText";

@interface VTextTypeTool ()

@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSDictionary *attributes;
@property (nonatomic, strong, readwrite) UIColor *dimmingBackgroundColor;
@property (nonatomic, strong, readwrite) NSString *placeholderText;
@property (nonatomic, assign, readwrite) VTextTypeVerticalAlignment verticalAlignment;

@end

@implementation VTextTypeTool

#pragma mark - VHasManagedDependancies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _title = [dependencyManager stringForKey:kTitleKey];
        
        _attributes = [self textAttributesWithDependencyManager:dependencyManager];
        
        _verticalAlignment = [self verticalAlignmentWithDependencyManager:dependencyManager];

        _placeholderText = [dependencyManager stringForKey:kTextToolPlaceholderText];
    }
    return self;
}

#pragma mark - Internal Methods

- (NSDictionary *)textAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] init];
    
    textAttributes[NSParagraphStyleAttributeName] = [self paragraphStyleWithDependencyManager:dependencyManager];
    
    if ([dependencyManager fontForKey:kParagraphFontKey] != nil)
    {
        textAttributes[NSFontAttributeName] = [dependencyManager fontForKey:kParagraphFontKey];
    }
    if ([dependencyManager colorForKey:kMainTextColorKey])
    {
        textAttributes[NSForegroundColorAttributeName] = [dependencyManager colorForKey:kMainTextColorKey];
    }
    if ([dependencyManager colorForKey:kTextToolStrokeColor])
    {
        textAttributes[NSStrokeColorAttributeName] = [dependencyManager colorForKey:kTextToolStrokeColor];
    }
    if ([dependencyManager numberForKey:kTextToolStrokeWidth])
    {
        textAttributes[NSStrokeWidthAttributeName] = [dependencyManager numberForKey:kTextToolStrokeWidth];
    }
    
    return textAttributes;
}

- (VTextTypeVerticalAlignment)verticalAlignmentWithDependencyManager:(VDependencyManager *)dependencyManager
{
    if ([dependencyManager stringForKey:kTextToolVerticalAlignment] == nil)
    {
        return VTextTypeVerticalAlignmentCenter;
    }
    
    NSString *textToolVerticalAlignment = [dependencyManager stringForKey:kTextToolVerticalAlignment];
    if ([textToolVerticalAlignment isEqualToString:@"bottom"])
    {
        return VTextTypeVerticalAlignmentBottomUp;
    }
    else if ([textToolVerticalAlignment isEqualToString:@"center"])
    {
        return VTextTypeVerticalAlignmentCenter;
    }
    else
    {
        return VTextTypeVerticalAlignmentCenter;
    }
}

- (NSParagraphStyle *)paragraphStyleWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    NSString *textHorizontalAlignment = [dependencyManager stringForKey:kTextToolHorizontalAlignment];
    if (textHorizontalAlignment != nil)
    {
        if ([textHorizontalAlignment isEqualToString:@"center"])
        {
            paragraphStyle.alignment = NSTextAlignmentCenter;
        }
        else if ([textHorizontalAlignment isEqualToString:@"left"])
        {
            paragraphStyle.alignment = NSTextAlignmentLeft;
        }
        else if ([textHorizontalAlignment isEqualToString:@"right"])
        {
            paragraphStyle.alignment = NSTextAlignmentRight;
        }
    }
    return paragraphStyle;
}

@end
