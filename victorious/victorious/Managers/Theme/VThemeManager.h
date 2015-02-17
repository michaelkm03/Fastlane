//
//  VThemeManager.h
//  victoriOS
//
//  Created by Gary Philipp on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - New Theme Constants
extern NSString * const kVCreatorName;

// Images

extern NSString * const kVMenuBackgroundImage;
extern NSString * const kVMenuBackgroundImage5;
extern NSString * const VThemeManagerHomeHeaderImageKey;

//Fonts
extern NSString * const kVHeaderFont;

extern NSString * const kVHeading1Font;
extern NSString * const kVHeading2Font;
extern NSString * const kVHeading3Font;
extern NSString * const kVHeading4Font;

extern NSString * const kVParagraphFont;

extern NSString * const kVLabel1Font;
extern NSString * const kVLabel2Font;
extern NSString * const kVLabel3Font;
extern NSString * const kVLabel4Font;

extern NSString * const kVButton1Font;
extern NSString * const kVButton2Font;

//Colors
extern NSString * const kVBackgroundColor;

extern NSString * const kVMainTextColor;
extern NSString * const kVContentTextColor;

extern NSString * const kVAccentColor;
extern NSString * const kVSecondaryAccentColor;

extern NSString * const kVLinkColor;
extern NSString * const kVSecondaryLinkColor;

@interface VThemeManager : NSObject

+ (VThemeManager *)sharedThemeManager;

- (void)setTheme:(NSDictionary *)dictionary;
- (void)updateToNewTheme;

- (UIImage *)themedBackgroundImageForDevice;
- (UIColor *)preferredBackgroundColor;

- (NSString *)themedStringForKey:(NSString *)key;
- (UIColor *)themedColorForKey:(NSString *)key;
- (NSURL *)themedURLForKey:(NSString *)key;
- (NSURL *)themedImageURLForKey:(NSString *)key;
- (UIImage *)themedImageForKey:(NSString *)key;
- (UIFont *)themedFontForKey:(NSString *)key;

@end
