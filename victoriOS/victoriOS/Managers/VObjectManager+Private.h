//
//  VObjectManager+Private.h
//  victoriOS
//
//  Created by David Keegan on 12/10/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager.h"

@interface VObjectManager (Private)

+ (RKManagedObjectRequestOperation *)POST:(NSString *)path parameters:(NSDictionary *)parameters block:(void(^)(id result, NSError *error))block;

@end
