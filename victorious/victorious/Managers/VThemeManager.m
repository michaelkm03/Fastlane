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
NSString*   const   kMenuTextFont                       =   @"theme.font.menu";
NSString*   const   kMenuTextColor                      =   @"theme.color.menu.label";

#pragma mark - Fonts
NSString*   const   kVStreamLocationFont                =   @"theme.font.stream.text.location";
NSString*   const   kVStreamUsernameFont                =   @"theme.font.stream.text.username";
NSString*   const   kVStreamDateFont                    =   @"theme.font.stream.text.date";
NSString*   const   kVStreamDescriptionFont             =   @"theme.font.stream.text.description";

NSString*   const   kVCommentUsernameFont               =   @"theme.font.comment.text.username";

NSString*   const   kVCreatePostFont                    =   @"theme.font.post";
NSString*   const   kVCreatePostButtonFont              =   @"theme.font.post.postButton";

#pragma mark - Colors
NSString*   const   kVStreamSearchBarColor              =   @"theme.color.stream.searchbar";

NSString*   const   kVCreatePollQuestionBorderColor     =   @"theme.color.post.poll.questions.border";
NSString*   const   kVCreatePollQuestionColor           =   @"theme.color.text.post.poll.question";
NSString*   const   kVCreatePollQuestionLeftColor       =   @"theme.color.text.post.poll.questions.left";
NSString*   const   kVCreatePollQuestionRightColor      =   @"theme.color.text.post.poll.questions.right";
NSString*   const   kVCreatePollQuestionLeftBGColor     =   @"theme.color.post.poll.questions.left.background";
NSString*   const   kVCreatePollQuestionRightBGColor    =   @"theme.color.post.poll.questions.right.background";

NSString*   const   kVCreatePostBackgroundColor         =   @"theme.color.post.background";
NSString*   const   kVCreatePostMediaLabelColor         =   @"theme.color.text.post.mediaLabel";
NSString*   const   kVCreatePostMediaButtonColor        =   @"theme.color.post.mediaButton.icon";
NSString*   const   kVCreatePostMediaButtonBGColor      =   @"theme.color.post.mediaButton.background";
NSString*   const   kVCreatePostTextColor               =   @"theme.color.text.post";
NSString*   const   KVRemoveMediaButtonColor            =   @"theme.color.post.media.remove";
NSString*   const   kVCreatePostInputBorderColor        =   @"theme.color.post.input.border";
NSString*   const   kVCreatePostButtonTextColor         =   @"theme.color.text.post.postButton";
NSString*   const   kVCreatePostButtonBGColor           =   @"theme.color.post.postButton.background";
NSString*   const   kVCreatePostCountInvalidColor       =   @"theme.color.text.post.count.invalid";
NSString*   const   kVCreatePostCountColor              =   @"theme.color.text.post.count";
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

- (void)applyStyling
{
    [[[[UIApplication sharedApplication] delegate] window] setTintColor:[self themedColorForKeyPath:@"theme.color"]];

    [[UINavigationBar appearance] setTintColor:[self themedColorForKeyPath:@"theme.color.navigationBar"]];
    [[UINavigationBar appearance] setBarTintColor:[self themedTranslucencyColorForKeyPath:@"theme.color.navigationBar.background"]];

    NSMutableDictionary *titleAttributes = [NSMutableDictionary dictionary];
    UIColor *navigationBarTitleTintColor = [self themedColorForKeyPath:@"theme.color.navigationBar.title"];
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
