//
//  VThemeManager.m
//  victoriOS
//
//  Created by Gary Philipp on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VThemeManager.h"

#import "VSettingManager.h"

#pragma mark - new theme constants

NSString * const   kVChannelName                       =   @"channel.name";

NSString * const   kVMenuBackgroundImage               =   @"Default";
NSString * const   kVMenuBackgroundImage5              =   @"Default-568h";
NSString * const   VThemeManagerHomeHeaderImageKey     =   @"homeHeaderImage";

#pragma mark - Fonts

NSString * const   kVHeaderFont                        =   @"font.header";

NSString * const   kVHeading1Font                      =   @"font.heading1";
NSString * const   kVHeading2Font                      =   @"font.heading2";
NSString * const   kVHeading3Font                      =   @"font.heading3";
NSString * const   kVHeading4Font                      =   @"font.heading4";

NSString * const   kVParagraphFont                     =   @"font.paragraph";

NSString * const   kVLabel1Font                        =   @"font.label1";
NSString * const   kVLabel2Font                        =   @"font.label2";
NSString * const   kVLabel3Font                        =   @"font.label3";
NSString * const   kVLabel4Font                        =   @"font.label4";

NSString * const   kVButton1Font                       =   @"font.button1";
NSString * const   kVButton2Font                       =   @"font.button2";

#pragma mark - Colors

NSString * const   kVBackgroundColor                   =   @"color.background";
NSString * const   kVSecondaryBackgroundColor          =   @"color.bacground.secondary";

NSString * const   kVMainTextColor                     =   @"color.text";
NSString * const   kVContentTextColor                  =   @"color.text.content";

NSString * const   kVAccentColor                       =   @"color.accent";
NSString * const   kVSecondaryAccentColor              =   @"color.accent.secondary";

NSString * const   kVLinkColor                         =   @"color.link";
NSString * const   kVSecondaryLinkColor                =   @"color.link.secondary";

NSString * const   kVNewThemeKey                       =   @"kVNewTheme";

#pragma mark - Feedback Support

NSString * const   kVChannelURLSupport                 =   @"email.support";

static CGFloat const kGreyBackgroundColor = 0.94509803921;

@implementation VThemeManager

+ (VThemeManager *)sharedThemeManager
{
    static  VThemeManager  *sharedThemeManager;
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
        NSURL  *defaultThemeURL =   [[NSBundle mainBundle] URLForResource:@"defaultTheme" withExtension:@"plist"];
        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfURL:defaultThemeURL]];
    }
    
    return self;
}

#pragma mark -

- (void)setTheme:(NSDictionary *)dictionary
{
    [[NSUserDefaults standardUserDefaults] setObject:dictionary forKey:kVNewThemeKey];
    [self updateToNewTheme];
}

- (void)updateToNewTheme
{
    NSDictionary *newTheme = [[NSUserDefaults standardUserDefaults] objectForKey:kVNewThemeKey];
    
    [newTheme enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         BOOL valid = YES;
         if ([obj respondsToSelector:@selector(length)])
         {
             valid = ((NSString *)obj).length;
         }
         
         if (obj && valid)
         {
             [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
         }
     }];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kVNewThemeKey];
}

#pragma mark -

- (void)applyStyling
{
    [[[[UIApplication sharedApplication] delegate] window] setTintColor:[self themedColorForKey:kVMainTextColor]];
    
    [self applyNormalNavBarStyling];
}

- (void)removeStyling
{
    [[[[UIApplication sharedApplication] delegate] window] setTintColor:nil];

    [self removeNavBarStyling];
}

- (void)applyNormalNavBarStyling
{
    [[UINavigationBar appearance] setTintColor:[self themedColorForKey:kVMainTextColor]];
    [[UINavigationBar appearance] setBarTintColor:[self themedTranslucencyColorForKey:kVAccentColor]];
    
    NSMutableDictionary *titleAttributes = [NSMutableDictionary dictionary];
    UIColor *navigationBarTitleTintColor = [self themedColorForKey:kVMainTextColor];
    if (navigationBarTitleTintColor)
    {
        titleAttributes[NSForegroundColorAttributeName] = navigationBarTitleTintColor;
    }
    UIFont *navigationBarTitleFont = [self themedFontForKey:kVHeaderFont];
    if (navigationBarTitleFont)
    {
        titleAttributes[NSFontAttributeName] = navigationBarTitleFont;

        NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary: [[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateNormal]];
        attributes[NSFontAttributeName] = navigationBarTitleFont;
        [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    }

    [[UINavigationBar appearance] setTitleTextAttributes:titleAttributes];
    
    [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:nil];
}

- (void)applyClearNavBarStyling
{
    [[UINavigationBar appearance] setTintColor:[self themedColorForKey:kVContentTextColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor clearColor]];
    
    NSMutableDictionary *titleAttributes = [NSMutableDictionary dictionary];
    UIColor *navigationBarTitleTintColor = [self themedColorForKey:kVContentTextColor];
    if (navigationBarTitleTintColor)
    {
        titleAttributes[NSForegroundColorAttributeName] = navigationBarTitleTintColor;
    }
    UIFont *navigationBarTitleFont = [self themedFontForKey:kVHeaderFont];
    if (navigationBarTitleFont)
    {
        titleAttributes[NSFontAttributeName] = navigationBarTitleFont;
        
        NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary: [[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateNormal]];
        attributes[NSFontAttributeName] = navigationBarTitleFont;
        [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    }
    
    [[UINavigationBar appearance] setTitleTextAttributes:titleAttributes];
    
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
}

- (void)removeNavBarStyling
{
    [[UINavigationBar appearance] setTintColor:nil];
    [[UINavigationBar appearance] setBarTintColor:nil];
    [[UINavigationBar appearance] setTitleTextAttributes:nil];
    
    [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:nil];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:nil forState:UIControlStateNormal];
}

#pragma mark - Primitives

- (id)themedValueForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key] ?: [NSNull null];
}

- (NSString *)themedStringForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:key] ?: @"";
}

- (NSURL *)themedURLForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] URLForKey:key] ?: [NSURL URLWithString:@""];
}

#pragma mark - Other

- (UIColor *)preferredBackgroundColor
{
    if ([[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled])
    {
        return [UIColor colorWithWhite:kGreyBackgroundColor alpha:1];
    }
    else
    {
        return [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor];
    }
}

- (UIImage *)themedBackgroundImageForDevice
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone &&
        [[UIScreen mainScreen] bounds].size.height == 568.0f)
    {
        return [self themedImageForKey:kVMenuBackgroundImage5];
    }
    else
    {
        return [self themedImageForKey:kVMenuBackgroundImage];
    }
}

- (UIColor *)themedColorForKey:(NSString *)key
{
    NSDictionary   *colorDictionary =   [self themedValueForKey:key];
    if (nil == colorDictionary)
    {
        return [UIColor clearColor];
    }

    CGFloat         red             =   [colorDictionary[@"red"] doubleValue] / 255.0;
    CGFloat         green           =   [colorDictionary[@"green"] doubleValue] / 255.0;
    CGFloat         blue            =   [colorDictionary[@"blue"] doubleValue] / 255.0;
    CGFloat         alpha           =   [colorDictionary[@"alpha"] doubleValue];
    UIColor        *color           =   [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    
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
    NSURL  *url =   [self themedURLForKey:key];
    if (!url)
    {
        url = [[NSBundle mainBundle] URLForResource:key withExtension:@"png"];
    }
    return url ?: [NSURL URLWithString:@""];
}

- (UIImage *)themedImageForKey:(NSString *)key
{
    // This is a terrible hack. By default the header image is a 1x1 pt image. If this is what we get back in themedImageForKey return nil.
    if ([key isEqualToString:VThemeManagerHomeHeaderImageKey])
    {
        UIImage *headerImage = [UIImage imageNamed:VThemeManagerHomeHeaderImageKey];
        if ((headerImage.size.width == 1) && (headerImage.size.height == 1))
        {
            return nil;
        }
        return headerImage;
    }
    
    return [UIImage imageNamed:key];
}

- (UIFont *)themedFontForKey:(NSString *)key
{
    NSDictionary   *fontDictionary = [self themedValueForKey:key];
    NSString       *fontName    =   fontDictionary[@"fontName"];
    CGFloat         fontSize    =   [fontDictionary[@"fontSize"] doubleValue];
    
    if (0 == fontSize)
    {
        fontSize = [UIFont systemFontSize];
    }
    
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    if (font)
    {
        return font;
    }
    else
    {
        return [UIFont systemFontOfSize:fontSize];
    }
}

@end
