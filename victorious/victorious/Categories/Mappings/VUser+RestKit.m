//
//  User+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/27/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VUser+RestKit.h"
#import "VUserHashtag+RestKit.h"

@implementation VUser (RestKit)

+ (NSString *)entityName
{
    return @"User";
}

#pragma mark - RestKit

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"id" : VSelectorName(remoteId),
                                  @"email" : VSelectorName(email),
                                  @"profile_tagline" : VSelectorName(tagline),
                                  @"profile_image" : VSelectorName(pictureUrl),
                                  @"profile_location" : VSelectorName(location),
                                  @"name" : VSelectorName(name),
                                  @"access_level" : VSelectorName(accessLevel),
                                  @"token" : VSelectorName(token),
                                  @"token_updated_at" : VSelectorName(tokenUpdatedAt),
                                  @"is_direct_message_disabled" : VSelectorName(isDirectMessagingDisabled),
                                  @"status" : VSelectorName(status),
                                  @"following" : VSelectorName(isFollowing),
                                  @"number_of_followers" : VSelectorName(numberOfFollowers),
                                  //@"hashtags" : VSelectorName(hashtags),
                                  };

    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];

    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];

    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    [mapping addConnectionForRelationship:@"comments" connectedBy:@{@"remoteId" : @"userId"}];
    [mapping addConnectionForRelationship:@"conversation" connectedBy:@{@"remoteId" : @"other_interlocutor_user_id"}];
    [mapping addConnectionForRelationship:@"messages" connectedBy:@{@"remoteId" : @"senderUserId"}];
    [mapping addConnectionForRelationship:@"hashtags" connectedBy:@{@"remoteId" : @"userId"}];
    
//    RKRelationshipMapping *hashtagsMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"hashtags"
//                                                                                          toKeyPath:VSelectorName(hashtags)
//                                                                                        withMapping:[VUserHashtag entityMapping]];
//    [mapping addPropertyMapping:hashtagsMapping];


    return mapping;
}

+ (NSArray *)descriptors
{
    return @[
             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodAny
                                                     pathPattern:@"/api/userinfo/fetch"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodAny
                                                     pathPattern:@"/api/userinfo/fetch/:userId"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodAny
                                                     pathPattern:@"/api/message/participants/:conversationId"
                                                         keyPath:@"payload.other_user"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodAny
                                                     pathPattern:@"/api/message/participants/:conversationId"
                                                         keyPath:@"payload.me"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],

             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/api/follow/subscribed_to_list/:userId/:page/:perpage"
                                                         keyPath:@"payload.users"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/api/follow/followers_list/:userId/:page/:perpage"
                                                         keyPath:@"payload.users"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/api/repost/all/:sequenceId/:page/:perpage"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],

             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodAny
                                                     pathPattern:@"/api/login/:logintype"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodAny
                                                     pathPattern:@"/api/login"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodAny
                                                     pathPattern:@"/api/account/update"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodAny
                                                     pathPattern:@"/api/account/create/:createType"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodAny
                                                     pathPattern:@"/api/account/create"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],

             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodAny
                                                     pathPattern:@"/api/friend/suggest"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodAny
                                                     pathPattern:@"/api/friend/find_by_email"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodAny
                                                     pathPattern:@"/api/friend/find/facebook/:token"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],

             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodAny
                                                     pathPattern:@"/api/friend/find/instagram/:token/:secret"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],

             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodAny
                                                     pathPattern:@"/api/friend/find/twitter/:token/:secret"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodAny
                                                     pathPattern:@"/api/userinfo/search"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodAny
                                                     pathPattern:@"/api/discover/users"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodAny
                                                     pathPattern:@"/api/hashtag/subscribed_to_list"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]
             ];
}

- (BOOL)isEqualToUser:(VUser *)user
{
    if (!self.remoteId || !user.remoteId)
    {
        return NO;
    }
    
    return [self.remoteId isEqualToNumber:user.remoteId];
}

@end