//
//  VUserProfileNavigationDestination.h
//  victorious
//
//  Created by Josh Hinman on 11/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDeeplinkHandler.h"
#import "VHasManagedDependencies.h"
#import "VNavigationDestination.h"

#import <Foundation/Foundation.h>

@class VObjectManager;

/**
 A navigation destination of the current user's own profile
 */
@interface VUserProfileNavigationDestination : NSObject <VDeeplinkSupporter, VHasManagedDependencies, VNavigationDestination>

- (instancetype)init NS_UNAVAILABLE;

@end
