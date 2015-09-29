//
//  VConversation+RestKit.m
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConversation+RestKit.h"
#import "VMessage+RestKit.h"
#import "VUser+RestKit.h"

@implementation VConversation (RestKit)

+ (NSString *)entityName
{
    return @"Conversation";
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"conversation_id" : VSelectorName(remoteId),
                                  @"text" : VSelectorName(lastMessageText),
                                  @"posted_at": VSelectorName(postedAt),
                                  @"is_read": VSelectorName(isRead),
                                  @"media_type" : VSelectorName(lastMessageContentType),
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    RKRelationshipMapping *userMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"other_interlocutor_user" toKeyPath:VSelectorName(user) withMapping:[VUser simpleMapping]];
    [mapping addPropertyMapping:userMapping];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

+ (NSArray *)descriptors
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
