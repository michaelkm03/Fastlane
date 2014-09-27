//
//  VActionItem.h
//  victorious
//
//  Created by Michael Sena on 9/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VActionItemType)
{
    VActionItemTypeDefault,
    VActionItemTypeUser,
    VActionItemTypeDescriptionWithHashTags,
};

/**
 A VActionItem represents a single item in a VActionsheetViewController. Note: does not support changing properties so everything must be available at instantiation.
 */
@interface VActionItem : NSObject

/**
 *  A convenience initializer for action items of the default type. Will place title, detail text, and action item in the corresponding readonly properties.
 *
 *  @param title      Copied
 *  @param actionIcon Not copied.
 *  @param detailText Copied
 *
 *  @return An initialized action item for default actions
 */
+ (instancetype)defaultActionItemWithTitle:(NSString *)title
                                actionIcon:(UIImage *)actionIcon
                                detailText:(NSString *)detailText;

+ (instancetype)userActionItemUserWithTitle:(NSString *)title
                                  avatarURL:(NSURL *)avatarURL
                                 detailText:(NSString *)detailText;

+ (instancetype)descriptionActionItemWithText:(NSString *)text;

@property (nonatomic, readonly) VActionItemType type;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *detailText;
@property (nonatomic, readonly) UIImage *icon;
@property (nonatomic, readonly) NSURL *avatarURL;

/**
 *  Called when the item is selected.
 */
@property (nonatomic, copy) void (^selectionHandler)(void);

/**
 *  Called when the item's accessory is selected. For default this will correspond to the detail text being selected.
 */
@property (nonatomic, copy) void (^detailSelectionHandler)(void);

@end
