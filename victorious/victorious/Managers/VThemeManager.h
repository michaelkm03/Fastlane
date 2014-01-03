//
//  VThemeManager.h
//  victoriOS
//
//  Created by Gary Philipp on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern  NSString*   const   kVThemeManagerThemeDidChange;

extern  NSString*   const   kVApplicationName;
extern  NSString*   const   kVApplicationTintColor;

extern  NSString*   const   kVNavigationBarBackgroundTintColor;
extern  NSString*   const   kVNavigationBarTintColor;
extern  NSString*   const   kVNavigationBarTitleTintColor;

extern  NSString*   const   kVMenuHeaderImageUrl;
extern  NSString*   const   kVMenuLabelFont;
extern  NSString*   const   kVMenuLabelColor;
extern  NSString*   const   kVMenuSeparatorColor;

extern  NSString*   const   kVStreamCellTextColor;
extern  NSString*   const   kVStreamCellIconColor;
extern  NSString*   const   kVStreamCellTextFont;
extern  NSString*   const   kVStreamCellTextUsernameFont;

extern  NSString*   const   kVSettingsAboutUsURL;
extern  NSString*   const   kVSettingsPrivacyPoliciesURL;
extern  NSString*   const   kVSettingsAcknowledgementsURL;

@interface VThemeManager : NSObject

+ (VThemeManager *)sharedThemeManager;

- (void)setTheme:(NSDictionary *)dictionary;

- (id)themedValueForKeyPath:(NSString *)keyPath;

- (UIColor *)themedColorForKeyPath:(NSString *)keyPath;

/** Retrieve a color from the theme that has been modified
 to look correct when used in a translucent view.
 */
- (UIColor *)themedTranslucencyColorForKeyPath:(NSString *)keyPath;

- (NSURL *)themedImageURLForKeyPath:(NSString *)keyPath;
- (UIFont *)themedFontForKeyPath:(NSString *)keyPath;

- (NSURL *)themedURLForKey:(NSString *)key;

@end
