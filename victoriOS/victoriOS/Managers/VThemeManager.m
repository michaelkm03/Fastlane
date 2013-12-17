//
//  VThemeManager.m
//  victoriOS
//
//  Created by Gary Philipp on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VThemeManager.h"

NSString*   const   kVThemeManagerThemeDidChange    =   @"VThemeManagerThemeDidChange";

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
                      sharedThemeManager = [[VThemeManager alloc] init];
                  });
    
    return sharedThemeManager;
}

- (id)init
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

- (id)themedValueForKey:(NSString *)key
{
    return self.themeValues[key];
}

#pragma mark -

@end
