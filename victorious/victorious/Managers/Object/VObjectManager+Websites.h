//
//  VObjectManager+Websites.h
//  victorious
//
//  Created by Will Long on 6/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"

typedef void (^VWebsiteCompletion) (NSOperation *completion, NSString *htmlString, NSError *error);

@interface VObjectManager (Websites)

- (RKManagedObjectRequestOperation *)fetchToSWithCompletionBlock:(VWebsiteCompletion)completionBlock;

@end
