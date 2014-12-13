//
//  VTextType.m
//  victorious
//
//  Created by Michael Sena on 12/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTextTypeTool.h"
#import "VDependencyManager.h"

static NSString * const kTitleKey = @"title";
static NSString * const kTextToolHorizontalAlignment = @"textToolHorizontalAlignment";
static NSString * const kTextToolVerticalAlignment = @"textToolVerticalAlignment";
static NSString * const kTextToolFont = @"textToolFont";
static NSString * const kTextToolColor = @"textToolColor";
static NSString * const kTextToolStrokeColor = @"textToolStrokeColor";
static NSString * const kTextToolStrokeWidth = @"textToolStrokeWidth";

@interface VTextTypeTool ()

@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSDictionary *attributes;
@property (nonatomic, strong, readwrite) UIColor *dimmingBackgroundColor;
//@property (nonatomic, copy, readwrite) NSString *placeholderText;
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
        
        NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] init];

        textAttributes[NSParagraphStyleAttributeName] = [self paragraphStyleWithDependencyManager:dependencyManager];
        textAttributes[NSFontAttributeName] = [dependencyManager fontForKey:kTextToolFont];
        textAttributes[NSForegroundColorAttributeName] = [dependencyManager colorForKey:kTextToolColor];
        textAttributes[NSStrokeColorAttributeName] = [dependencyManager colorForKey:kTextToolStrokeColor];
        textAttributes[NSStrokeWidthAttributeName] = [dependencyManager numberForKey:kTextToolStrokeWidth];
        
        _attributes = [NSDictionary dictionaryWithDictionary:textAttributes];
    }
    return self;
}

#pragma mark - Internal Methods

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
