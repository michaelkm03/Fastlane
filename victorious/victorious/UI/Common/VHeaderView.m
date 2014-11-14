//
//  VHeaderView.m
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHeaderView.h"
#import "VSettingManager.h"

@implementation VHeaderView

+ (NSString *)preferredNibForThemeForClass:(Class)aClass
{
    if ( [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled] )
    {
        return [NSStringFromClass( aClass ) stringByAppendingString:@"-C"];
    }
    else
    {
        return NSStringFromClass( aClass );
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self applyTheme];
}

- (void)applyTheme
{
    // Override in subclasses
}

@end
