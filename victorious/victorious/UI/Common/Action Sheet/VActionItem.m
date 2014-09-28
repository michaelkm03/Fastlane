//
//  VActionItem.m
//  victorious
//
//  Created by Michael Sena on 9/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VActionItem.h"

@interface VActionItem ()

@property (nonatomic, assign, readwrite) VActionItemType type;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSString *detailText;
@property (nonatomic, strong, readwrite) UIImage *icon;
@property (nonatomic, strong, readwrite) NSURL *avatarURL;

@end

@implementation VActionItem

#pragma mark - Factory Methods

+ (instancetype)defaultActionItemWithTitle:(NSString *)title
                                actionIcon:(UIImage *)actionIcon
                                detailText:(NSString *)detailText
{
    VActionItem *actionItem = [[VActionItem alloc] init];
    actionItem.type = VActionItemTypeDefault;
    actionItem.title = [title copy];
    actionItem.detailText = [detailText copy];
    actionItem.icon = actionIcon;
    
    return actionItem;
}

+ (instancetype)userActionItemUserWithTitle:(NSString *)title
                                  avatarURL:(NSURL *)avatarURL
                                 detailText:(NSString *)detailText
{
    VActionItem *actionItem  = [[VActionItem alloc] init];
    actionItem.type = VActionItemTypeUser;
    actionItem.title = [title copy];
    actionItem.avatarURL = [avatarURL copy];
    actionItem.detailText = [detailText copy];

    return actionItem;
}


+ (instancetype)descriptionActionItemWithText:(NSString *)text
                      hashTagSelectionHandler:(void (^)(NSString *hashTag))hashTagSelectionHandler
{
    VActionItem *actionItem = [[VActionItem alloc] init];
    
    actionItem.type = VActionItemTypeDescriptionWithHashTags;
    actionItem.title = [text copy];
    actionItem.detailText = [text copy];
    actionItem.hashTagSelectionHandler = hashTagSelectionHandler;

    return actionItem;
}

@end
