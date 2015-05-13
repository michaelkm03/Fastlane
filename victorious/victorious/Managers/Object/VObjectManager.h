//
//  VObjectManager.h
//  victorious
//
//  Created by Will Long on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "RKObjectManager.h"
#import "VLoginType.h"

@class VUploadManager, VPaginationManager, VUser;

/*! Block that executes when the request succeeds. */
typedef void (^VSuccessBlock) (NSOperation *operation, id result, NSArray *resultObjects);
/*! Block that executes when the request fails. */
typedef void (^VFailBlock) (NSOperation *operation, NSError *error);

@interface VObjectManager : RKObjectManager

@property (nonatomic, readonly) VUser *mainUser; ///< The user the is currently logged in.

@property (nonatomic, readonly) VLoginType mainUserLoginType; ///< The type of login for the current user's current session.

@property (nonatomic, readonly) VPaginationManager *paginationManager; ///< An object responsible for tracking paginated responses

+ (void)setupObjectManager;

- (id)objectWithEntityName:(NSString *)entityName subclass:(Class)subclass;

- (void)resetSessionID;

@end
