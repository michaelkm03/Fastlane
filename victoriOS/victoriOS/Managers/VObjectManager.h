//
//  VObjectManager.h
//  victoriOS
//
//  Created by Will Long on 11/29/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "RKObjectManager.h"

@class VUser;

@interface VObjectManager : RKObjectManager

+ (void)setupObjectManager;

@end

@interface VObjectManager (Login)

+ (RKManagedObjectRequestOperation *)loginToVictoriousWithEmail:(NSString *)email password:(NSString *)password block:(void(^)(VUser *user, NSError *error))block;
+ (RKManagedObjectRequestOperation *)createVictoriousAccountWithEmail:(NSString *)email password:(NSString *)password name:(NSString *)name block:(void(^)(VUser *user, NSError *error))block;
+ (RKManagedObjectRequestOperation *)updateVictoriousAccountWithEmail:(NSString *)email password:(NSString *)password name:(NSString *)name block:(void(^)(VUser *user, NSError *error))block;

@end
