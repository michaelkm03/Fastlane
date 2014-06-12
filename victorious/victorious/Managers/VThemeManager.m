//
//  VThemeManager.m
//  victoriOS
//
//  Created by Gary Philipp on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VThemeManager.h"
#import <AVFoundation/AVAssetExportSession.h>
#import <AVFoundation/AVCaptureSession.h>

#pragma mark - new theme constants
NSString*   const   kVThemeManagerThemeDidChange        =   @"VThemeManagerThemeDidChange";

NSString*   const   kVChannelURLAbout                   =   @"channel.url.about";
NSString*   const   kVChannelURLPrivacy                 =   @"channel.url.privacy";
NSString*   const   kVChannelURLAcknowledgements        =   @"channel.url.acknowledgements";
NSString*   const   kVChannelURLSupport                 =   @"channel.url.support";
NSString*   const   kVChannelName                       =   @"channel.name";
NSString*   const   kVAppStoreURL                       =   @"appstore.url";

NSString*   const   kVCaptureVideoQuality               =   @"capture";
NSString*   const   kVExportVideoQuality                =   @"remix";

NSString*   const   kVAgreementText                     =   @"agreement.text";
NSString*   const   kVAgreementLinkText                 =   @"agreement.linkText";
NSString*   const   kVAgreementLink                     =   @"agreement.link";

NSString*   const   kVMenuBackgroundImage               =   @"Default";
NSString*   const   kVMenuBackgroundImage5              =   @"Default-568h";

#pragma mark - Fonts

NSString*   const   kVHeaderFont                        =   @"font.header";

NSString*   const   kVHeading1Font                      =   @"font.heading1";
NSString*   const   kVHeading2Font                      =   @"font.heading2";
NSString*   const   kVHeading3Font                      =   @"font.heading3";
NSString*   const   kVHeading4Font                      =   @"font.heading4";

NSString*   const   kVParagraphFont                     =   @"font.paragraph";

NSString*   const   kVLabel1Font                        =   @"font.label1";
NSString*   const   kVLabel2Font                        =   @"font.label2";
NSString*   const   kVLabel3Font                        =   @"font.label3";
NSString*   const   kVLabel4Font                        =   @"font.label4";

NSString*   const   kVButton1Font                       =   @"font.button1";
NSString*   const   kVButton2Font                       =   @"font.button2";


#pragma mark - Colors
NSString*   const   kVBackgroundColor                   =   @"color.background";
NSString*   const   kVSecondaryBackgroundColor          =   @"color.bacground.secondary";
NSString*   const   kVCancelColor                       =   @"color.cancel";

NSString*   const   kVMainTextColor                     =   @"color.text";
NSString*   const   kVContentTextColor                  =   @"color.text.content";

NSString*   const   kVAccentColor                       =   @"color.accent";
NSString*   const   kVSecondaryAccentColor              =   @"color.accent.secondary";

NSString*   const   kVLinkColor                         =   @"color.link";
NSString*   const   kVSecondaryLinkColor                =   @"color.link.secondary";

NSString*   const   kVNewThemeKey                       =   @"kVNewTheme";

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
    [[NSUserDefaults standardUserDefaults] setObject:dictionary forKey:kVNewThemeKey];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kVThemeManagerThemeDidChange object:self userInfo:nil];
}

- (void)updateToNewTheme
{
    NSDictionary* newTheme = [[NSUserDefaults standardUserDefaults] objectForKey:kVNewThemeKey];
    
    [newTheme enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
     }];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kVNewThemeKey];
}

#pragma mark -

- (void)applyStyling
{
    [[[[UIApplication sharedApplication] delegate] window] setTintColor:[self themedColorForKey:kVMainTextColor]];
    
    [self applyNormalNavBarStyling];
    
//    [[UITabBar appearanceWhenContainedIn:[UITabBar class], nil] setTintColor:[UIColor redColor]];
//    [[UITabBar appearance] setSelectedImageTintColor:[UIColor greenColor]];
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

- (NSString *)themedExportVideoQuality
{
    NSString*   value   =   [self themedStringForKey:kVExportVideoQuality];
    
    if ([value isEqualToString:@"low"])
        return  AVAssetExportPresetLowQuality;
    else if ([value isEqualToString:@"medium"])
        return  AVAssetExportPresetMediumQuality;
    else if ([value isEqualToString:@"high"])
        return  AVAssetExportPresetHighestQuality;
    else
        return AVAssetExportPresetMediumQuality;
}

- (NSString *)themedCapturedVideoQuality
{
    NSString*   value   =   [self themedStringForKey:kVCaptureVideoQuality];

    if ([value isEqualToString:@"low"])
        return  AVCaptureSessionPresetLow;
    else if ([value isEqualToString:@"medium"])
        return  AVCaptureSessionPresetMedium;
    else if ([value isEqualToString:@"high"])
        return  AVCaptureSessionPresetHigh;
    else
        return AVCaptureSessionPresetMedium;
}
@end
