//
//  VShareMenuItem.h
//  victorious
//
//  Created by Sharif Ahmed on 6/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VHasManagedDependencies.h"

typedef NS_ENUM(NSInteger, VShareType)
{
    VShareTypeFacebook,
    VShareTypeTwitter,
    VShareTypeUnknown,
};

/**
    A menu item describing a social network that can be shared to.
 */
@interface VShareMenuItem : NSObject <VHasManagedDependencies>

/**
    Creates a new menu item with the provided properties.
 
    @param title The display title of this share menu item.
    @param icon The unselected icon of this share menu item.
    @param selectedIcon The selected icon of this share menu item.
    @param shareType A typedef describing what social network this share menu item represents.
 
    @return A new share menu item setup with the provided properties.
 */
- (instancetype)initWithTitle:(NSString *)title
                         icon:(UIImage *)icon
                 selectedIcon:(UIImage *)selectedIcon
                    shareType:(VShareType)shareType;

/**
    Creates a new share menu item based on the properties found in the provided dependency manager.
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

@property (nonatomic, readonly) NSString *title; ///< The display title of this share menu item.
@property (nonatomic, readonly) UIImage *icon; ///< The unselected icon of this share menu item.
@property (nonatomic, readonly) UIImage *selectedIcon; ///< The selected icon of this share menu item.
@property (nonatomic, readonly) VShareType shareType; ///< A typedef describing what social network this share menu item represents.

@end
