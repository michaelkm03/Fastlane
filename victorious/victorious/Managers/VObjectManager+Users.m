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

@implementation VObjectManager (Users)

static NSMutableDictionary *userRelationships;

- (RKManagedObjectRequestOperation *)fetchUser:(NSNumber*)userId
                         forrelationshipObject:(id)relationshipObject
                              withSuccessBlock:(SuccessBlock)success
                                     failBlock:(FailBlock)fail
{
//    return nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userRelationships = [[NSMutableDictionary alloc] init];
    });
    
    @synchronized(userRelationships)
    {
        NSMutableArray* relationships = [userRelationships objectForKey:userId];

        //There's nothing to add and we're already fetching the object
        if (!relationshipObject && relationships)
            return nil;
        
        //We're already fetching this ID, just add the object and return
        if (relationships && [relationships isKindOfClass:[NSMutableArray class]])
        {
            VLog(@"Found relationships: %@", relationships);
            [relationships addObject:relationshipObject];
            [userRelationships setObject:userRelationships forKey:userId];
            return nil;
        }
        
        relationships = [[NSMutableArray alloc] init];
        [relationships addObject:relationshipObject];
        [userRelationships setObject:relationships forKey:userId];
        VLog(@"Added object: %@.  All relationships: %@ ", [relationshipObject class], userRelationships);
    }

    NSString* path = userId ? [NSString stringWithFormat:@"/api/userinfo/fetch/%@", userId] : @"/api/userinfo/fetch";
    
    SuccessBlock fullSuccess = ^(NSArray* resultObjects)
    {
        [self addRelationshipsForUsers:resultObjects];
        if (success)
            success(resultObjects);
    };
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail
     paginationBlock:nil];
}

- (void)addRelationshipsForUsers:(NSArray*)users
{
    @synchronized(userRelationships)
    {
        for (VUser* user in users)
        {
            NSArray* relationships = [userRelationships objectForKey:user.remoteId];
            for (id relationshipObject in relationships)
            {
                if ([relationshipObject isKindOfClass:[VComment class]])
                    ((VComment*)relationshipObject).user = user;
                
                else if ([relationshipObject isKindOfClass:[VMessage class]])
                    ((VMessage*)relationshipObject).user = user;
                
                else if ([relationshipObject isKindOfClass:[VSequence class]])
                    ((VSequence*)relationshipObject).user = user;
                
                else if ([relationshipObject isKindOfClass:[VConversation class]])
                    [((VConversation*)relationshipObject) addUsersObject:user];
            }
            
            [userRelationships removeObjectForKey:user.remoteId];
        }
    }
}

@end
