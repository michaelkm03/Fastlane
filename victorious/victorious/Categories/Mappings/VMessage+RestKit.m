//
//  VMessage+RestKit.m
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMessage+RestKit.h"

#import "VMedia+RestKit.h"

@implementation VMessage (RestKit)

+ (NSString *)entityName
{
    return @"Message";
}

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"is_read" : VSelectorName(isRead),
                                  @"text" : VSelectorName(text),
                                  @"sender_user_id" : VSelectorName(senderUserId),
                                  @"posted_at" : VSelectorName(postedAt)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];

    [mapping addConnectionForRelationship:@"user" connectedBy:@{@"senderUserId" : @"remoteId"}];

    [mapping addRelationshipMappingWithSourceKeyPath:VSelectorName(media) mapping:[VMedia entityMapping]];
    
    return mapping;
}

+ (RKResponseDescriptor*)descriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"api/message/conversation/%@"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

@end
