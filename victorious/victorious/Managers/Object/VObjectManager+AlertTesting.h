//
//  VObjectManager+AlertTesting.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VObjectManager.h"

@interface VObjectManager (AlertTesting)

# warning Class and methods are for testing only

- (RKManagedObjectRequestOperation *)registerTestAlert:(VSuccessBlock)success
                                             failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)acknowledgeAlert:(NSString *)alertID
                                          withSuccess:(VSuccessBlock)success
                                             failBlock:(VFailBlock)fail;

@end
