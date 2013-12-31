//
//  VThemeManager.m
//  victoriOS
//
//  Created by Gary Philipp on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VThemeManager.h"

NSString*   const   kVThemeManagerThemeDidChange        =   @"VThemeManagerThemeDidChange";

NSString*   const   kVApplicationName                   =   @"applicationName";
NSString*   const   kVApplicationTintColor              =   @"applicationTintColor";

NSString*   const   kVNavigationBarBackgroundTintColor  =   @"navigationBarBackgroundTintColor";
NSString*   const   kVNavigationBarTintColor            =   @"navigationBarTintColor";
NSString*   const   kVNavigationBarTitleTintColor       =   @"navigationBarTitleTintColor";

NSString*   const   kVMenuHeaderImageUrl                =   @"menuHeaderImageUrl";
NSString*   const   kVMenuLabelFont                     =   @"menuLabelFont";
NSString*   const   kVMenuLabelColor                    =   @"menuLabelColor";
NSString*   const   kVMenuSeparatorColor                =   @"menuSeparatorColor";

NSString*   const   kVStreamCellTextColor               =   @"streamCellTextColor";
NSString*   const   kVStreamCellIconColor               =   @"streamCellIconColor";
NSString*   const   kVStreamCellTextFont                =   @"streamCellTextFont";
NSString*   const   kVStreamCellTextUsernameFont        =   @"streamCellTextUsernameFont";

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

- (id)themedValueForKey:(NSString *)key
{
    return self.themeValues[key];
}

- (UIColor *)themedColorForKey:(NSString *)key
{
    NSDictionary*   colorDictionary =   [self themedValueForKey:key];
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

- (UIColor *)themedTranslucencyColorForKey:(NSString *)key
{
    UIColor *color = [self themedColorForKey:key];

    // From https://github.com/kgn/UIColorCategories
    CGFloat hue = 0, saturation = 0, brightness = 0, alpha = 0;
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    return [UIColor colorWithHue:hue saturation:saturation*1.158 brightness:brightness*0.95 alpha:alpha];
}

- (NSURL *)themedImageURLForKey:(NSString *)key
{
    NSURL*  url =   [NSURL URLWithString:[self themedValueForKey:key]];
    if (nil == url)
        url     =   [[NSBundle mainBundle] URLForResource:key withExtension:@"png"];
    return url;
}

- (UIFont *)themedFontForKey:(NSString *)key
{
    NSDictionary*   fontDictionary = [self themedValueForKey:key];
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
