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

#pragma mark - Colors
NSString*   const   kVAccentColor                       =   @"color.accent";
NSString*   const   kVContentAccentColor                =   @"color.accent.content";

NSString*   const   kVMainColor                         =   @"color.main";

NSString*   const   kVSecondaryMainColor                =   @"color.main.secondary";

NSString*   const   kVLinkColor                         =   @"color.link";

#pragma mark - old theme constants
#pragma mark - Fonts
NSString*   const   kMenuTextFont                       =   @"font";

NSString*   const   kVStreamLocationFont                =   @"font";
NSString*   const   kVStreamUsernameFont                =   @"font";
NSString*   const   kVStreamDateFont                    =   @"font";
NSString*   const   kVStreamDescriptionFont             =   @"font";

NSString*   const   kVCommentUsernameFont               =   @"font";

NSString*   const   kVCreatePostFont                    =   @"font";
NSString*   const   kVCreatePostButtonFont              =   @"font";

NSString*   const   kVProfileUsernameFont               =   @"font";
NSString*   const   kVProfileLocationFont               =   @"font";
NSString*   const   kVProfileTaglineFont                =   @"font";



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
        NSURL*  defaultThemeURL =   [[NSBundle mainBundle] URLForResource:@"carlyTheme" withExtension:@"plist"];
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
    [[[[UIApplication sharedApplication] delegate] window] setTintColor:[self themedColorForKey:kVAccentColor]];

    [[UINavigationBar appearance] setTintColor:[self themedColorForKey:kVAccentColor]];
    [[UINavigationBar appearance] setBarTintColor:[self themedTranslucencyColorForKey:kVMainColor]];

    NSMutableDictionary *titleAttributes = [NSMutableDictionary dictionary];
    UIColor *navigationBarTitleTintColor = [self themedColorForKey:kVAccentColor];
    if(navigationBarTitleTintColor)
    {
        [titleAttributes setObject:navigationBarTitleTintColor forKey:NSForegroundColorAttributeName];
    }
    UIFont *navigationBarTitleFont = [self themedFontForKey:@"theme.font.navigationBar.title"];
    if(navigationBarTitleFont)
    {
        [titleAttributes setObject:navigationBarTitleFont forKey:NSFontAttributeName];
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

#pragma mark -

- (id)themedValueForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (NSString *)themedStringForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

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

- (NSURL *)themedURLForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] URLForKey:key];
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
