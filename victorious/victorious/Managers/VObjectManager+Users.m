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
    NSArray* sequences = [self objectsForEntity:[VSequence entityName]
                                      userIdKey:@"createdBy"
                                         userId:user.remoteId
                                      inContext:user.managedObjectContext];
    for (VSequence* sequence in sequences)
    {
        sequence.user = user;
    }
    
    NSArray* comments = [self objectsForEntity:[VComment entityName]
                                     userIdKey:@"userId"
                                        userId:user.remoteId
                                     inContext:user.managedObjectContext];
    for (VComment* comment in comments)
    {
        comment.user = user;
    }
    
    NSArray* conversations = [self objectsForEntity:[VConversation entityName]
                                          userIdKey:@"other_interlocutor_user_id"
                                             userId:user.remoteId
                                          inContext:user.managedObjectContext];
    for (VConversation* conversation in conversations)
    {
        conversation.user = user;
    }
    
    NSArray* messages = [self objectsForEntity:[VConversation entityName]
                                          userIdKey:@"senderUserId"
                                             userId:user.remoteId
                                          inContext:user.managedObjectContext];
    for (VConversation* message in messages)
    {
        message.user = user;
    }
    
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
