//
//  VThemeManager.m
//  victoriOS
//
//  Created by Gary Philipp on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VThemeManager.h"
#import "VDependencyManager.h"
#import "VSettingManager.h"

#pragma mark - new theme constants

NSString * const   kVCreatorName                       =   @"creator.name";

NSString * const   kVMenuBackgroundImage               =   @"LaunchImage";
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

NSString * const   kVMainTextColor                     =   @"color.text";
NSString * const   kVContentTextColor                  =   @"color.text.content";

NSString * const   kVAccentColor                       =   @"color.accent";
NSString * const   kVSecondaryAccentColor              =   @"color.accent.secondary";

NSString * const   kVLinkColor                         =   @"color.link";
NSString * const   kVSecondaryLinkColor                =   @"color.link.secondary";

NSString * const   kVNewThemeKey                       =   @"kVNewTheme";

#pragma mark - Feedback Support

NSString * const   kVSupportEmail                      =   @"email.support";

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

#pragma mark - Primitives

- (id)themedValueForKey:(NSString *)key
{
    return [self.dependencyManager templateValueOfType:[NSObject class] forKey:key] ?: [NSNull null];
}

- (NSString *)themedStringForKey:(NSString *)key
{
    return [self.dependencyManager stringForKey:key] ?: @"";
}

#pragma mark - Other

- (UIColor *)preferredBackgroundColor
{
    return [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
}

- (UIImage *)themedBackgroundImageForDevice
{
    return [self themedImageForKey:kVMenuBackgroundImage];
}

- (UIColor *)themedColorForKey:(NSString *)key
{
    return [self.dependencyManager colorForKey:key];
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
    return [self.dependencyManager fontForKey:key];
}

@end
