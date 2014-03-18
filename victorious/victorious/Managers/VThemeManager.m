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
NSString*   const   kVChannelURLSupport                 =   @"channel.url.support";
NSString*   const   kVChannelName                       =   @"channel.name";

NSString*   const   kVAgreementText                     =   @"agreement.text";
NSString*   const   kVAgreementLinkText                 =   @"agreement.linkText";
NSString*   const   kVAgreementLink                     =   @"agreement.link";

NSString*   const   kVMenuBackgroundImage               =   @"LaunchImage-700";
NSString*   const   kVMenuBackgroundImage5              =   @"LaunchImage-700-568h";

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

#pragma mark - Colors
NSString*   const   kMenuTextColor                      =   @"color.main";

NSString*   const   kVAccentColor                       =   @"color.accent";
NSString*   const   kVMainColor                         =   @"color.main";
NSString*   const   kVSecondaryMainColor                =   @"color.main.secondary";
NSString*   const   kVLinkColor                         =   @"color.link";

NSString*   const   kVStreamSearchBarColor              =   @"color.main";

NSString*   const   kVCreatePollQuestionBorderColor     =   @"color.main";
NSString*   const   kVCreatePollQuestionColor           =   @"color.main";
NSString*   const   kVCreatePollQuestionLeftColor       =   @"color.main";
NSString*   const   kVCreatePollQuestionRightColor      =   @"color.main";
NSString*   const   kVCreatePollQuestionLeftBGColor     =   @"color.main";
NSString*   const   kVCreatePollQuestionRightBGColor    =   @"color.main";

NSString*   const   kVCreatePostBackgroundColor         =   @"color.main";
NSString*   const   kVCreatePostMediaLabelColor         =   @"color.main";
NSString*   const   kVCreatePostMediaButtonColor        =   @"color.main";
NSString*   const   kVCreatePostMediaButtonBGColor      =   @"color.main";
NSString*   const   kVCreatePostTextColor               =   @"color.main";
NSString*   const   KVRemoveMediaButtonColor            =   @"color.main";
NSString*   const   kVCreatePostInputBorderColor        =   @"color.main";
NSString*   const   kVCreatePostButtonTextColor         =   @"color.main";
NSString*   const   kVCreatePostButtonBGColor           =   @"color.main";
NSString*   const   kVCreatePostCountInvalidColor       =   @"color.main";
NSString*   const   kVCreatePostCountColor              =   @"color.main";

NSString*   const   kVProfileLocationColor              =   @"color.main";



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

- (void)applyStyling
{
    [[[[UIApplication sharedApplication] delegate] window] setTintColor:[self themedColorForKeyPath:kVAccentColor]];

    [[UINavigationBar appearance] setTintColor:[self themedColorForKeyPath:kVAccentColor]];
    [[UINavigationBar appearance] setBarTintColor:[self themedTranslucencyColorForKeyPath:kVMainColor]];

    NSMutableDictionary *titleAttributes = [NSMutableDictionary dictionary];
    UIColor *navigationBarTitleTintColor = [self themedColorForKeyPath:kVAccentColor];
    if(navigationBarTitleTintColor)
    {
        [titleAttributes setObject:navigationBarTitleTintColor forKey:NSForegroundColorAttributeName];
    }
    UIFont *navigationBarTitleFont = [self themedFontForKeyPath:@"theme.font.navigationBar.title"];
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

- (id)themedValueForKeyPath:(NSString *)keyPath
{
    id value = self.themeValues[keyPath];

    if (value)
        return value;

    NSString *newKeyPath = [keyPath stringByDeletingPathExtension];
    if ([keyPath isEqualToString:newKeyPath])
        return nil;

    return [self themedValueForKeyPath:newKeyPath];
}

- (NSString *)themedStringForPath:(NSString *)keyPath
{
    return (NSString *)[self themedValueForKeyPath:keyPath];
}

- (UIColor *)themedColorForKeyPath:(NSString *)keyPath
{
    NSDictionary*   colorDictionary =   [self themedValueForKeyPath:keyPath];
    if (nil == colorDictionary)
        return nil;

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

- (UIImage *)themedImageForKeyPath:(NSString *)keyPath
{
    return [UIImage imageNamed:keyPath];
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

@end
