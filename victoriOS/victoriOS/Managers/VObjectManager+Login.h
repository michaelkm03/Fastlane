//
//  VObjectManager+Login.h
//  victoriOS
//
//  Created by David Keegan on 12/10/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager.h"

@class VUser;

@interface VObjectManager (Login)

+ (void)loginToFacebook;

+ (RKManagedObjectRequestOperation *)loginToVictoriousWithEmail:(NSString *)email password:(NSString *)password block:(void(^)(VUser *user, NSError *error))block;
+ (RKManagedObjectRequestOperation *)createVictoriousAccountWithEmail:(NSString *)email password:(NSString *)password name:(NSString *)name block:(void(^)(VUser *user, NSError *error))block;
+ (RKManagedObjectRequestOperation *)updateVictoriousAccountWithEmail:(NSString *)email password:(NSString *)password name:(NSString *)name block:(void(^)(VUser *user, NSError *error))block;

@end
