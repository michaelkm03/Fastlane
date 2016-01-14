//
//  VObjectManager.h
//  victorious
//
//  Created by Will Long on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLoginType.h"

@import RestKit;

NS_ASSUME_NONNULL_BEGIN

@class VUploadManager, VPaginationManager, VUser;

/*! Block that executes when the request succeeds. */
typedef void (^VSuccessBlock) (NSOperation *__nullable operation, id __nullable result, NSArray *resultObjects);
/*! Block that executes when the request fails. */
typedef void (^VFailBlock) (NSOperation *__nullable operation, NSError *__nullable error);

@interface VObjectManager : RKObjectManager

@property (nonatomic, readonly, nullable) VUser *mainUser; ///< The user the is currently logged in.
@property (nonatomic, readonly) VLoginType mainUserLoginType; ///< The type of login for the current user's current session.
@property (nonatomic, readonly) VPaginationManager *paginationManager; ///< An object responsible for tracking paginated responses
@property (nonatomic, readonly) VUploadManager *uploadManager; ///< An object responsible for uploading files
@property (nonatomic, strong, nullable) NSSet *experimentIDs; //<A set that stores all of the users experimental IDs

@property (nonatomic, readonly) NSMutableDictionary<NSString*, RKEntityMapping*> *mappingCache; ///< A place to store mappings so they don't have to be constantly re-created

+ (void)setupObjectManagerWithUploadManager:(VUploadManager *)uploadManager;

- (id)objectWithEntityName:(NSString *)entityName subclass:(Class)subclass;

- (void)resetSessionID;

@end

NS_ASSUME_NONNULL_END