//
//  User+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/27/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VUser+RestKit.h"

@implementation VUser (RestKit)

+ (NSString *)entityName
{
    return @"User";
}

#pragma mark - RestKit

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"id" : VSelectorName(remoteId),
                                  @"email" : VSelectorName(email),
                                  @"profile_tagline" : VSelectorName(tagline),
                                  @"profile_image" : VSelectorName(pictureUrl),
                                  @"profile_location" : VSelectorName(location),
                                  @"name" : VSelectorName(name),
                                  @"short_name" : VSelectorName(shortName),
                                  @"access_level" : VSelectorName(accessLevel),
                                  @"token" : VSelectorName(token),
                                  @"token_updated_at" : VSelectorName(tokenUpdatedAt)
                                  };

    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];

    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];

    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    [mapping addConnectionForRelationship:@"comments" connectedBy:@{@"remoteId" : @"userId"}];
    [mapping addConnectionForRelationship:@"conversations" connectedBy:@{@"remoteId" : @"other_interlocutor_user_id"}];
    [mapping addConnectionForRelationship:@"messages" connectedBy:@{@"remoteId" : @"senderUserId"}];
//    [mapping addConnectionForRelationship:@"pollResults" connectedBy:@{@"remoteId" : @"other_interlocutor_user_id"}];
    [mapping addConnectionForRelationship:@"postedSequences" connectedBy:@{@"remoteId" : @"createdBy"}];

    return mapping;
}

+ (NSArray*)descriptors
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
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]
             ];
}

- (BOOL)isEqualToUser:(VUser *)user
{
    if(!self.remoteId || !user.remoteId)
    {
        return NO;
    }
    
    return [self.remoteId isEqualToNumber:user.remoteId];
}

@end