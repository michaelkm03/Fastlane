//
//  VCommentsUtilityButtonConfiguration.m
//  victorious
//
//  Created by Patrick Lynch on 12/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCommentsUtilityButtonConfiguration.h"

@implementation VUtilityButtonConfig

@end

@implementation VCommentsUtilityButtonConfiguration

+ (VCommentsUtilityButtonConfiguration *)sharedInstance
{
    static VCommentsUtilityButtonConfiguration *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      instance = [[VCommentsUtilityButtonConfiguration alloc] init];
                      [instance createUtilityButtonConfigurations];
                  });
    return instance;
}

- (void)createUtilityButtonConfigurations
{
    self.editButtonConfig = [[VUtilityButtonConfig alloc] init];
    self.editButtonConfig.backgroundColor = [UIColor colorWithWhite:0.75f alpha:1.0f];
    self.editButtonConfig.iconImage = [UIImage imageNamed:@"edit_icon"];
    
    self.deleteButtonConfig = [[VUtilityButtonConfig alloc] init];
    self.deleteButtonConfig.backgroundColor = [UIColor colorWithWhite:0.47f alpha:1.0f];
    self.deleteButtonConfig.iconImage = [UIImage imageNamed:@"trash_icon"];
    
    self.flagButtonConfig = [[VUtilityButtonConfig alloc] init];
    self.flagButtonConfig.backgroundColor = [UIColor colorWithWhite:0.75f alpha:1.0f];
    self.flagButtonConfig.iconImage = [UIImage imageNamed:@"warning_icon"];
}

@end