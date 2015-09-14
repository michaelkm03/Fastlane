//
//  VDependencyManager+VAvatarBadgeAppearance.h
//  victorious
//
//  Created by Sharif Ahmed on 9/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"

extern NSString * const VDependencyManagerAvatarBadgeAppearanceMinLevelKey;
extern NSString * const VDependencyManagerAvatarBadgeAppearanceBackgroundColorKey;
extern NSString * const VDependencyManagerAvatarBadgeAppearanceTextColorKey;

@interface VDependencyManager (VAvatarBadgeAppearance)

@property (nonatomic, readonly) VDependencyManager *avatarBadgeAppearanceDependencyManager;

@end
