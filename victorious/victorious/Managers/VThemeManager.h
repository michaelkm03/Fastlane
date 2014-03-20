//
//  VThemeManager.h
//  victoriOS
//
//  Created by Gary Philipp on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern  NSString*   const   kVThemeManagerThemeDidChange;

#pragma mark - New Theme Constants
extern  NSString*   const   kVChannelURLAbout;
extern  NSString*   const   kVChannelURLPrivacy;
extern  NSString*   const   kVChannelURLAcknowledgements;
extern  NSString*   const   kVChannelURLSupport;
extern  NSString*   const   kVChannelName;

extern  NSString*   const   kVAgreementText;
extern  NSString*   const   kVAgreementLinkText;
extern  NSString*   const   kVAgreementLink;

extern  NSString*   const   kVMenuBackgroundImage;
extern  NSString*   const   kVMenuBackgroundImage5;

//Fonts
extern  NSString*   const   kVTitleFont;
extern  NSString*   const   kVContentTitleFont;
extern  NSString*   const   kVDetailFont;
extern  NSString*   const   kVDateFont;
extern  NSString*   const   kVButtonFont;
extern  NSString*   const   kVPollButtonFont;


//Colors
extern  NSString*   const   kVAccentColor;
extern  NSString*   const   kVContentAccentColor;

extern  NSString*   const   kVMainColor;
extern  NSString*   const   kVSecondaryMainColor;

extern  NSString*   const   kVLinkColor;

@interface VThemeManager : NSObject

+ (VThemeManager *)sharedThemeManager;

- (void)setTheme:(NSDictionary *)dictionary;

- (void)applyStyling;
- (void)removeStyling;

- (id)themedValueForKeyPath:(NSString *)keyPath;

- (NSString *)themedStringForPath:(NSString *)keyPath;
- (UIColor *)themedColorForKeyPath:(NSString *)keyPath;
- (UIColor *)themedTranslucencyColorForKeyPath:(NSString *)keyPath;
- (NSURL *)themedURLForKeyPath:(NSString *)keyPath;
- (NSURL *)themedImageURLForKeyPath:(NSString *)keyPath;
- (UIImage *)themedImageForKeyPath:(NSString *)keyPath;
- (UIFont *)themedFontForKeyPath:(NSString *)keyPath;

@end
