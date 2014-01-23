//
//  VObjectManager+Users.m
//  victorious
//
//  Created by Will Long on 1/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+Users.h"
#import "VObjectManager+Private.h"

#import "VConversation+RestKit.h"
#import "VComment+RestKit.h"
#import "VMessage+RestKit.h"
#import "VSequence+RestKit.h"
#import "VUser+RestKit.h"

#import "VConstants.h"

@interface VObjectManager (UserProperties)
@property (nonatomic, strong) VSuccessBlock fullSuccess;
@property (nonatomic, strong) VFailBlock fullFail;
@end

@implementation VObjectManager (Users)

- (RKManagedObjectRequestOperation *)fetchUser:(NSNumber*)userId
                              withSuccessBlock:(VSuccessBlock)success
                                     failBlock:(VFailBlock)fail
{
    VUser* user = (VUser*)[self objectForID:userId
                                      idKey:kRemoteIdKey
                                 entityName:[VUser entityName]];
    if (user)
    {
        if (success)
            success(nil, nil, @[user]);
        
        return nil;
    }
    
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
//    __block NSMutableArray* loadedUsers = [[NSMutableArray alloc] init];
//    NSMutableArray* unloadedUserIDs = [[NSMutableArray alloc] init];
//    for (NSNumber* userID in [[NSSet setWithArray:userIds] allObjects])
//    {
//        VUser* user = [self userForID:userID];
//        if (user)
//            [loadedUsers addObject:user];
//        else
//            [unloadedUserIDs addObject:userID];
//    }
//    
//    if (![unloadedUserIDs count])
//    {
//        success(nil, nil, loadedUsers);
//        return nil;
//    }
//    
//    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
//    {
//        for (VUser* user in resultObjects)
//        {
//            [self addRelationshipsForUser:user];
//            [loadedUsers addObject:user];
//        }
//        
//        if (success)
//            success(operation, fullResponse, loadedUsers);
//    };
//    
//    return [self GET:@"/api/userinfo/fetchmany"
//              object:nil
//          parameters:@{@"user_ids":unloadedUserIDs}
//        successBlock:fullSuccess
//           failBlock:fail];
    
    for (NSNumber* userID in [[NSSet setWithArray:userIds] allObjects])
    {
        [self fetchUser:userID
       withSuccessBlock:success
              failBlock:fail];
    }
    if (success && ![userIds count])
        success(nil, nil, nil);
    
    return nil;
}

- (void)addRelationshipsForUser:(VUser*)user
{
    NSSet* sequences = [NSSet setWithArray:[self objectsForEntity:[VSequence entityName]
                                                        userIdKey:@"createdBy"
                                                           userId:user.remoteId
                                                        inContext:user.managedObjectContext]];
    [user addPostedSequences:sequences];
    
    NSSet* commments = [NSSet setWithArray:[self objectsForEntity:[VComment entityName]
                                                        userIdKey:@"userId"
                                                           userId:user.remoteId
                                                        inContext:user.managedObjectContext]];
    [user addComments:commments];
    
    NSSet* conversations = [NSSet setWithArray:[self objectsForEntity:[VConversation entityName]
                                                            userIdKey:@"other_interlocutor_user_id"
                                                               userId:user.remoteId
                                                            inContext:user.managedObjectContext]];
    [user addConversations:conversations];
    
    NSSet* messages = [NSSet setWithArray:[self objectsForEntity:[VMessage entityName]
                                                       userIdKey:@"senderUserId"
                                                          userId:user.remoteId
                                                       inContext:user.managedObjectContext]];
    [user addMessages:messages];
    
    [user.managedObjectContext save:nil];
    
    VLog(@"User sequences: %@", user.postedSequences);
}

- (NSArray*)objectsForEntity:(NSString*)entityName
                   userIdKey:(NSString*)idKey
                      userId:(NSNumber*)userId
                   inContext:(NSManagedObjectContext*)context
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate* idFilter = [NSPredicate predicateWithFormat:@"%K == %@", idKey, userId];
    [request setPredicate:idFilter];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error != nil)
    {
        VLog(@"Error occured in user objectsForEntity: %@", error);
    }
    return results;
}

@end
