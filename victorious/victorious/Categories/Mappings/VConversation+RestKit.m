//
//  VConversation+RestKit.m
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConversation+RestKit.h"
#import "VMessage+RestKit.h"

@implementation VConversation (RestKit)

+ (NSString *)entityName
{
    return @"Conversation";
}

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"conversation_id" : VSelectorName(remoteId),
                                  @"other_interlocutor_user_id" : VSelectorName(other_interlocutor_user_id),
                                  @"text" : VSelectorName(lastMessageText),
                                  @"posted_at": VSelectorName(postedAt),
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    [mapping addConnectionForRelationship:@"user" connectedBy:@{@"other_interlocutor_user_id" : @"remoteId"}];
    
    RKRelationshipMapping* messageMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:nil
                                                                                        toKeyPath:VSelectorName(messages)
                                                                                      withMapping:[VMessage entityMapping]];
    [mapping addPropertyMapping:messageMapping];
    
    return mapping;
}

+ (NSArray*)descriptors
{
    return @[ [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/message/conversation_list"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                           method:RKRequestMethodGET
                                                      pathPattern:@"/api/message/conversation_list/:currentpage/:perpage"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                           method:RKRequestMethodGET
                                                      pathPattern:@"/api/message/conversation_with_user/:userid/:currentpage/:perpage"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                           method:RKRequestMethodGET
                                                      pathPattern:@"/api/message/conversation_with_user/:userid"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]
              ];
}

@end
