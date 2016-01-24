//
//  VMessage+RestKit.m
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMessage+RestKit.h"
#import "VMediaAttachment.h"

@implementation VMessage (RestKit)

+ (NSString *)entityName
{
    return @"Message";
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"text" : VSelectorName(text),
                                  @"sender_user_id" : VSelectorName(senderUserId),
                                  @"posted_at" : VSelectorName(postedAt),
                                  @"thumbnail_url" : VSelectorName(thumbnailUrl),
                                  @"media_url" : VSelectorName(mediaUrl),
                                  @"message_id" : VSelectorName(remoteId),
                                  @"is_read" : VSelectorName(isRead),
                                  @"should_autoplay" : VSelectorName(shouldAutoplay),
                                  @"media_width" : VSelectorName(mediaWidth),
                                  @"media_height" : VSelectorName(mediaHeight)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];

    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];

    [mapping addAttributeMappingsFromDictionary:propertyMap];

    [mapping addConnectionForRelationship:@"sender" connectedBy:@{@"senderUserId" : @"remoteId"}];
    
    // Message media
    RKRelationshipMapping *messageMediaMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"media"
                                                                                             toKeyPath:VSelectorName(mediaAttachments)
                                                                                           withMapping:[VMediaAttachment entityMapping]];
    
    [mapping addPropertyMapping:messageMediaMapping];
    
    return mapping;
}

+ (NSArray *)descriptors
{
    return @[ [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/message/conversation/:id/:sort/:currentpage/:perpage"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                           method:RKRequestMethodGET
                                                      pathPattern:@"/api/message/conversation/:id/:sort"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
}

@end
