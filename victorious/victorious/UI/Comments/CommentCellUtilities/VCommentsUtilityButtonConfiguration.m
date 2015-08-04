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
    UIColor *backgroundColor = [UIColor colorWithWhite:0.75f alpha:1.0f];
    
    self.editButtonConfig = [[VUtilityButtonConfig alloc] init];
    self.editButtonConfig.backgroundColor = backgroundColor;
    self.editButtonConfig.iconImage = [UIImage imageNamed:@"editIcon"];
    self.editButtonConfig.type = VCommentCellUtilityTypeEdit;
    
    self.deleteButtonConfig = [[VUtilityButtonConfig alloc] init];
    self.deleteButtonConfig.backgroundColor = backgroundColor;
    self.deleteButtonConfig.iconImage = [UIImage imageNamed:@"trashIcon"];
    self.deleteButtonConfig.type = VCommentCellUtilityTypeDelete;
    
    self.flagButtonConfig = [[VUtilityButtonConfig alloc] init];
    self.flagButtonConfig.backgroundColor = backgroundColor;
    self.flagButtonConfig.iconImage = [UIImage imageNamed:@"warningIcon"];
    self.flagButtonConfig.type = VCommentCellUtilityTypeFlag;
    
    self.replyButtonConfig = [[VUtilityButtonConfig alloc] init];
    self.replyButtonConfig.backgroundColor = backgroundColor;
    self.replyButtonConfig.type = VCommentCellUtilityTypeReply;
    self.replyButtonConfig.iconImage = [UIImage imageNamed:@"replyIcon"];
}

@end