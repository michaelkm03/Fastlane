//
//  VThemeManager.h
//  victoriOS
//
//  Created by Gary Philipp on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern  NSString*   const   kVThemeManagerThemeDidChange;

@interface VThemeManager : NSObject

+ (VThemeManager *)sharedThemeManager;

- (void)setTheme:(NSDictionary *)dictionary;

- (id)themedValueForKey:(NSString *)key;

- (UIColor *)themedColorForKey:(NSString *)key;
- (NSURL *)themedImageURLForKey:(NSString *)key;
- (UIFont *)themedFontForKey:(NSString *)key;

@end
