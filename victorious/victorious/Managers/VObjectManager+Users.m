//
//  VObjectManager+Users.m
//  victorious
//
//  Created by Will Long on 1/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+Users.h"
#import "VObjectManager+Private.h"

#import "VConversation.h"
#import "VComment.h"
#import "VMessage.h"
#import "VSequence.h"
#import "VUser.h"

@interface VObjectManager (UserProperties)
@property (nonatomic, strong) VSuccessBlock fullSuccess;
@property (nonatomic, strong) VFailBlock fullFail;
@end

@implementation VObjectManager (Users)

- (RKManagedObjectRequestOperation *)fetchUser:(NSNumber*)userId
                              withSuccessBlock:(VSuccessBlock)success
                                     failBlock:(VFailBlock)fail
{
    NSString* path = userId ? [@"/api/userinfo/fetch/" stringByAppendingString: userId.stringValue] : @"/api/userinfo/fetch";
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        for (VUser* user in resultObjects)
            [self addRelationshipsForUser:user];
        
        if (success)
            success(operation, fullResponse, resultObjects);
    };
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *)fetchUsers:(NSArray*)userIds
                               withSuccessBlock:(VSuccessBlock)success
                                      failBlock:(VFailBlock)fail
{
    for (NSNumber* userID in [[NSSet setWithArray:userIds] allObjects])
    {
        [self fetchUser:userID
       withSuccessBlock:success
              failBlock:fail];
    }
    return nil;
}

- (void)addRelationshipsForUser:(VUser*)user
{
//    NSFetchRequest
}
@end
