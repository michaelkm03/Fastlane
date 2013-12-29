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

@interface VThemeManager : NSObject

+ (VThemeManager *)sharedThemeManager;

- (void)setTheme:(NSDictionary *)dictionary;

- (id)themedValueForKey:(NSString *)key;

- (UIColor *)themedColorForKey:(NSString *)key;

/** Retrieve a color from the theme that has been modified
 to look correct when used in a translucent view.
 */
- (UIColor *)themedTranslucencyColorForKey:(NSString *)key;

- (NSURL *)themedImageURLForKey:(NSString *)key;
- (UIFont *)themedFontForKey:(NSString *)key;

@end
