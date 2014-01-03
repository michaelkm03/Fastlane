//
//  VThemeManager.h
//  victoriOS
//
//  Created by Gary Philipp on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern  NSString*   const   kVThemeManagerThemeDidChange;

extern  NSString*   const   kVChannelURLAbout;
extern  NSString*   const   kVChannelURLPrivacy;
extern  NSString*   const   kVChannelURLAcknowledgements;

extern  NSString*   const   kVChannelURLSupport;

@interface VThemeManager : NSObject

+ (VThemeManager *)sharedThemeManager;

- (void)setTheme:(NSDictionary *)dictionary;

- (id)themedValueForKeyPath:(NSString *)keyPath;

- (UIColor *)themedColorForKeyPath:(NSString *)keyPath;

/** Retrieve a color from the theme that has been modified
 to look correct when used in a translucent view.
 */
- (UIColor *)themedTranslucencyColorForKeyPath:(NSString *)keyPath;

- (NSURL *)themedURLForKeyPath:(NSString *)keyPath;
- (NSURL *)themedImageURLForKeyPath:(NSString *)keyPath;
- (UIFont *)themedFontForKeyPath:(NSString *)keyPath;


@end
