//
//  VThemeManager.m
//  victoriOS
//
//  Created by Gary Philipp on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VThemeManager.h"

#pragma mark - new theme constants
NSString*   const   kVThemeManagerThemeDidChange        =   @"VThemeManagerThemeDidChange";

NSString*   const   kVChannelURLAbout                   =   @"channel.url.about";
NSString*   const   kVChannelURLPrivacy                 =   @"channel.url.privacy";
NSString*   const   kVChannelURLAcknowledgements        =   @"channel.url.acknowledgements";
NSString*   const   kVChannelURLSupport                 =   @"channel.url.support";
NSString*   const   kVChannelName                       =   @"channel.name";

NSString*   const   kVAgreementText                     =   @"agreement.text";
NSString*   const   kVAgreementLinkText                 =   @"agreement.linkText";
NSString*   const   kVAgreementLink                     =   @"agreement.link";

NSString*   const   kVMenuBackgroundImage               =   @"LaunchImage-700";
NSString*   const   kVMenuBackgroundImage5              =   @"LaunchImage-700-568h";

#pragma mark - Fonts

NSString*   const   kVTitleFont                         =   @"font.title";
NSString*   const   kVContentTitleFont                  =   @"font.title.content";

NSString*   const   kVDetailFont                        =   @"font.detail";
NSString*   const   kVDateFont                          =   @"font.date";

NSString*   const   kVButtonFont                        =   @"font.button";

NSString*   const   kVPollButtonFont                    =   @"font.button.poll";


#pragma mark - Colors
NSString*   const   kVBackgroundColor                   =   @"color.background";
NSString*   const   kVCancelColor                       =   @"color.cancel";

NSString*   const   kVMainTextColor                     =   @"color.text";
NSString*   const   kVContentTextColor                  =   @"color.text.content";

NSString*   const   kVAccentColor                       =   @"color.accent";
NSString*   const   kVSecondaryAccentColor              =   @"color.accent.secondary";

NSString*   const   kVLinkColor                         =   @"color.link";


@interface      VThemeManager   ()
@end

@implementation VThemeManager

+ (VThemeManager *)sharedThemeManager
{
    static  VThemeManager*  sharedThemeManager;
    static  dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,
                  ^{
                      sharedThemeManager = [[self alloc] init];
                  });
    
    return sharedThemeManager;
}

- (instancetype)init
{
    self    =   [super init];
    if (self)
    {
        NSURL*  defaultThemeURL =   [[NSBundle mainBundle] URLForResource:@"defaultTheme" withExtension:@"plist"];
        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfURL:defaultThemeURL]];
    }
    
    return self;
}

#pragma mark -

- (void)setTheme:(NSDictionary *)dictionary
{
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
        [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
    }];

    [[NSNotificationCenter defaultCenter] postNotificationName:kVThemeManagerThemeDidChange object:self userInfo:nil];
}


#pragma mark -

- (void)applyStyling
{
    [[[[UIApplication sharedApplication] delegate] window] setTintColor:[self themedColorForKey:kVMainTextColor]];

    [[UINavigationBar appearance] setTintColor:[self themedColorForKey:kVMainTextColor]];
    [[UINavigationBar appearance] setBarTintColor:[self themedTranslucencyColorForKey:kVAccentColor]];

    NSMutableDictionary *titleAttributes = [NSMutableDictionary dictionary];
    UIColor *navigationBarTitleTintColor = [self themedColorForKey:kVMainTextColor];
    if(navigationBarTitleTintColor)
    {
        titleAttributes[NSForegroundColorAttributeName] = navigationBarTitleTintColor;
    }
    UIFont *navigationBarTitleFont = [self themedFontForKey:kVTitleFont];
    if(navigationBarTitleFont)
    {
        titleAttributes[NSFontAttributeName] = navigationBarTitleFont;
    }
    [[UINavigationBar appearance] setTitleTextAttributes:titleAttributes];
}

- (void)removeStyling
{
    [[[[UIApplication sharedApplication] delegate] window] setTintColor:nil];

    [[UINavigationBar appearance] setTintColor:nil];
    [[UINavigationBar appearance] setBarTintColor:nil];
    [[UINavigationBar appearance] setTitleTextAttributes:nil];
}

#pragma mark - Primitives

- (id)themedValueForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (NSString *)themedStringForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

- (NSURL *)themedURLForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] URLForKey:key];
}

#pragma mark - Other

- (UIColor *)themedColorForKey:(NSString *)key
{
    NSDictionary*   colorDictionary =   [self themedValueForKey:key];
    if (nil == colorDictionary)
        return nil;

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
    NSURL*  url =   [self themedURLForKey:key];
    if (nil == url)
        url     =   [[NSBundle mainBundle] URLForResource:key withExtension:@"png"];
    return url;
}

- (UIImage *)themedImageForKey:(NSString *)key
{
    return [UIImage imageNamed:key];
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

@end
