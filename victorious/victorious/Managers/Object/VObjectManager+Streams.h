//
//  VObjectManager+Streams.h
//  victorious
//
//  Created by Will Long on 9/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"

@class VStream;

@interface VObjectManager (Streams)

- (RKManagedObjectRequestOperation *)fetchObjectsForStream:(VStream *)stream
                                                 isRefresh:(BOOL)refresh
                                              successBlock:(VSuccessBlock)success
                                                 failBlock:(VFailBlock)fail;

@end
