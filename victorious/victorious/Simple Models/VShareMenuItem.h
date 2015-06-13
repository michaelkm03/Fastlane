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

@interface VShareMenuItem : NSObject <VHasManagedDependencies>

- (instancetype)initWithTitle:(NSString *)title
                         icon:(UIImage *)icon
                 selectedIcon:(UIImage *)selectedIcon
                    shareType:(VShareType)shareType;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) UIImage *icon;
@property (nonatomic, readonly) UIImage *selectedIcon;
@property (nonatomic, readonly) VShareType shareType;

@end
