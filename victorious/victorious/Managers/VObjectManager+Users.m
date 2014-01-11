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

- (RKManagedObjectRequestOperation *)fetchUser:(NSNumber*)userId
                         forRelationshipObject:(id)relationshipObject
                              withSuccessBlock:(SuccessBlock)success
                                     failBlock:(FailBlock)fail
{

//    return nil;

//    DISPATCH_QUEUE_SERIAL
    
    @synchronized(self.userRelationships)
    {
        NSMutableArray* relationships = [self.userRelationships objectForKey:userId];

        //There's nothing to add and we're already fetching the object
        if (!relationshipObject && relationships)
            return nil;
        
        //We're already fetching this ID, just add the object and return
        if (relationships && [relationships isKindOfClass:[NSMutableArray class]])
        {
            VLog(@"Found relationships: %@", relationships);
            [relationships addObject:relationshipObject];
            [self.userRelationships setObject:relationships forKey:userId];
            
            return nil;
        }
        
        relationships = [[NSMutableArray alloc] init];
        [relationships addObject:relationshipObject];
        [self.userRelationships setObject:relationships forKey:userId];
        VLog(@"Added object: %@.  All relationships: %@ ", [relationshipObject class], self.userRelationships);
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
    @synchronized(self.userRelationships)
    {
        for (VUser* user in users)
        {
            NSArray* relationships = [self.userRelationships objectForKey:user.remoteId];
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
            
            [self.userRelationships removeObjectForKey:user.remoteId];
        }
    }
}

@end
