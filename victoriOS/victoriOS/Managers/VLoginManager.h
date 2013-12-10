//
//  VLoginManager.h
//  victoriOS
//
//  Created by Will Long on 11/27/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLoginManager : NSObject

+ (void)loginToFacebook;

+ (RKManagedObjectRequestOperation *)loginToVictoriousWithEmail:(NSString*)email password:(NSString*)password block:(void(^)(NSArray *categories, NSError *error))block;
+ (RKManagedObjectRequestOperation *)createVictoriousAccountWithEmail:(NSString*)email password:(NSString*)password name:(NSString*)name block:(void(^)(NSArray *categories, NSError *error))block;
+ (RKManagedObjectRequestOperation *)updateVictoriousAccountWithEmail:(NSString*)email password:(NSString*)password name:(NSString*)name block:(void(^)(NSArray *categories, NSError *error))block;

@end
