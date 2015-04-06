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

@property (nonatomic, strong, readonly) VObjectManager *objectManager; ///< The object manager provided in the -init call

/**
 Initializes a new instance of the receiver.
 
 @param objectManager An instance of VObjectManager used to retrieve the current user
 */
- (instancetype)initWithObjectManager:(VObjectManager *)objectManager NS_DESIGNATED_INITIALIZER;

@end
