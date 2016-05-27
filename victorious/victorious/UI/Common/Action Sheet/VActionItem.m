//
//  VActionItem.m
//  victorious
//
//  Created by Michael Sena on 9/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VActionItem.h"
#import "victorious-Swift.h"

@interface VActionItem ()

@property (nonatomic, assign, readwrite) VActionItemType type;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSString *detailText;
@property (nonatomic, strong, readwrite) UIImage *icon;
@property (nonatomic, strong, readwrite) VUser *user;
@property (nonatomic, assign, readwrite) BOOL enabled;

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

+ (instancetype)defaultActionItemWithTitle:(NSString *)title
                                actionIcon:(UIImage *)actionIcon
                                detailText:(NSString *)detailText
                                   enabled:(BOOL)enabled
{
    VActionItem *actionItem = [self defaultActionItemWithTitle:title
                                                    actionIcon:actionIcon
                                                    detailText:detailText];
    actionItem.enabled = enabled;
    return actionItem;
}

+ (instancetype)userActionItemUserWithTitle:(NSString *)title
                                       user:(VUser *)user
                                 detailText:(NSString *)detailText
{
    VActionItem *actionItem  = [[VActionItem alloc] init];
    actionItem.type = VActionItemTypeUser;
    actionItem.title = [title copy];
    actionItem.user = user;
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

#pragma mark - NSObject

- (id)init
{
    self = [super init];
    if (self)
    {
        _enabled = YES;
    }
    return self;
}

- (NSString *)description
{
    NSMutableString *descriptionString = [[super description] mutableCopy];
    if (self.title != nil)
    {
        [descriptionString appendString:[NSString stringWithFormat:@"title: %@", self.title]];
    }
    
    if (self.detailText != nil)
    {
        [descriptionString appendString:[NSString stringWithFormat:@"detailText: %@", self.detailText]];
    }
    
    if (self.user != nil)
    {
        [descriptionString appendString:[NSString stringWithFormat:@"userId: %@", self.user.remoteId]];
    }
    
    return descriptionString;
}

@end
