//
//  VConversation+RestKit.m
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConversation+RestKit.h"
#import "NSManagedObject+EasyFetching.h"
#import "VMessage+RestKit.h"

@implementation VConversation (RestKit)

+ (NSString *)entityName
{
    return @"Conversation";
}

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"conversation_id" : VSelectorName(remoteId)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:nil toKeyPath:@"messages" withMapping:[VMessage entityMapping]]];

    return mapping;
}

+ (RKResponseDescriptor*)descriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/message/conversation_list"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

@end
