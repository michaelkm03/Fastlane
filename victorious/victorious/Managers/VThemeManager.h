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

extern  NSString*   const   kVCaptureVideoQuality;
extern  NSString*   const   kVExportVideoQuality;

extern  NSString*   const   kVAgreementText;
extern  NSString*   const   kVAgreementLinkText;
extern  NSString*   const   kVAgreementLink;

extern  NSString*   const   kVMenuBackgroundImage;
extern  NSString*   const   kVMenuBackgroundImage5;

//Fonts
extern  NSString*   const   kVHeaderFont;

extern  NSString*   const   kVHeading1Font;
extern  NSString*   const   kVHeading2Font;
extern  NSString*   const   kVHeading3Font;
extern  NSString*   const   kVHeading4Font;

extern  NSString*   const   kVParagraphFont;

extern  NSString*   const   kVLabel1Font;
extern  NSString*   const   kVLabel2Font;
extern  NSString*   const   kVLabel3Font;
extern  NSString*   const   kVLabel4Font;

extern  NSString*   const   kVButton1Font;
extern  NSString*   const   kVButton2Font;

//Colors
extern  NSString*   const   kVBackgroundColor;
extern  NSString*   const   kVSecondaryBackgroundColor;
extern  NSString*   const   kVCancelColor;

extern  NSString*   const   kVMainTextColor;
extern  NSString*   const   kVContentTextColor;

extern  NSString*   const   kVAccentColor;
extern  NSString*   const   kVSecondaryAccentColor;

extern  NSString*   const   kVLinkColor;

@interface VThemeManager : NSObject

+ (VThemeManager *)sharedThemeManager;

- (void)setTheme:(NSDictionary *)dictionary;
- (void)updateToNewTheme;

- (void)applyStyling;
- (void)removeStyling;

- (void)applyNormalNavBarStyling;
- (void)applyClearNavBarStyling;
- (void)removeNavBarStyling;

- (NSString *)themedStringForKey:(NSString *)key;
- (UIColor *)themedColorForKey:(NSString *)key;
- (NSURL *)themedURLForKey:(NSString *)key;
- (NSURL *)themedImageURLForKey:(NSString *)key;
- (UIImage *)themedImageForKey:(NSString *)key;
- (UIFont *)themedFontForKey:(NSString *)key;

- (NSString *)themedExportVideoQuality;
- (NSString *)themedCapturedVideoQuality;

@end
