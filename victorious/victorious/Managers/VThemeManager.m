//
//  VThemeManager.m
//  victoriOS
//
//  Created by Gary Philipp on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VThemeManager.h"

NSString*   const   kVThemeManagerThemeDidChange        =   @"VThemeManagerThemeDidChange";

NSString*   const   kVChannelURLAbout                   =   @"channel.url.about";
NSString*   const   kVChannelURLPrivacy                 =   @"channel.url.privacy";
NSString*   const   kVChannelURLAcknowledgements        =   @"channel.url.acknowledgements";

@interface      VThemeManager   ()
@property   (nonatomic, readwrite, copy)    NSDictionary*   themeValues;
@end

@implementation VThemeManager

+ (VThemeManager *)sharedThemeManager
{
    static  VThemeManager*  sharedThemeManager;
    static  dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,
                  ^{
                      sharedThemeManager = [[VThemeManager alloc] init];
                  });
    
    return sharedThemeManager;
}

- (id)init
{
    self    =   [super init];
    if (self)
    {
        NSURL*  defaultThemeURL =   [[NSBundle mainBundle] URLForResource:@"defaultTheme" withExtension:@"plist"];
        _themeValues            =   [NSDictionary dictionaryWithContentsOfURL:defaultThemeURL];
    }
    
    return self;
}

#pragma mark -

- (void)setTheme:(NSDictionary *)dictionary
{
    self.themeValues = [dictionary copy];
    [[NSNotificationCenter defaultCenter] postNotificationName:kVThemeManagerThemeDidChange object:self userInfo:nil];
}

#pragma mark -

- (id)themedValueForKeyPath:(NSString *)keyPath
{
    id value = self.themeValues[keyPath];

    if (value)
    {
        return value;
    }

    NSString *newKeyPath = [keyPath stringByDeletingPathExtension];
    if ([keyPath isEqualToString:newKeyPath])
    {
        return nil;
    }

    return [self themedValueForKeyPath:newKeyPath];
}

- (UIColor *)themedColorForKeyPath:(NSString *)keyPath
{
    NSDictionary*   colorDictionary =   [self themedValueForKeyPath:keyPath];
    if (nil == colorDictionary)
    {
        return nil;
    }

    CGFloat         red             =   [colorDictionary[@"red"] doubleValue] / 255.0;
    CGFloat         green           =   [colorDictionary[@"green"] doubleValue] / 255.0;
    CGFloat         blue            =   [colorDictionary[@"blue"] doubleValue] / 255.0;
    CGFloat         alpha           =   [colorDictionary[@"alpha"] doubleValue];
    UIColor*        color           =   [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    return color;
}

- (UIColor *)themedTranslucencyColorForKeyPath:(NSString *)keyPath
{
    UIColor *color = [self themedColorForKeyPath:keyPath];

    // From https://github.com/kgn/UIColorCategories
    CGFloat hue = 0, saturation = 0, brightness = 0, alpha = 0;
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    return [UIColor colorWithHue:hue saturation:saturation*1.158 brightness:brightness*0.95 alpha:alpha];
}

- (NSURL *)themedURLForKeyPath:(NSString *)keyPath
{
    return [NSURL URLWithString:[self themedValueForKeyPath:keyPath]];
}

- (NSURL *)themedImageURLForKeyPath:(NSString *)keyPath
{
    NSURL*  url =   [self themedURLForKeyPath:keyPath];
    if (nil == url)
        url     =   [[NSBundle mainBundle] URLForResource:keyPath withExtension:@"png"];
    return url;
}

- (UIFont *)themedFontForKeyPath:(NSString *)keyPath
{
    NSDictionary*   fontDictionary = [self themedValueForKeyPath:keyPath];
    NSString*       fontName    =   fontDictionary[@"fontName"];
    CGFloat         fontSize    =   [fontDictionary[@"fontSize"] doubleValue];
    
    if (0 == fontSize)
        fontSize = [UIFont systemFontSize];
    
    if (0 == fontName.length)
        return [UIFont systemFontOfSize:fontSize];

    return [UIFont fontWithName:fontName size:fontSize];
}

#pragma mark -

@end
