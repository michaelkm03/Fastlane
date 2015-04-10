//
//  VNotification+RestKit.m
//  victorious
//
//  Created by Lawrence Leach on 8/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNotification+RestKit.h"
#import "VUser+RestKit.h"
#import "VMessage+RestKit.h"
#import "VUser+RestKit.h"

@implementation VNotification (RestKit)

+ (NSString *)entityName
{
    return @"Notification";
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"body" : VSelectorName(body),
                                  @"deeplink" : VSelectorName(deepLink),
                                  @"is_read" : VSelectorName(isRead),
                                  @"type" : VSelectorName(type),
                                  @"updated_at" : VSelectorName(updatedAt),
                                  @"id" : VSelectorName(remoteId),
                                  @"subject" : VSelectorName(subject),
                                  @"creator_profile_image_url" : VSelectorName(imageURL),
                                  @"created_at" : VSelectorName(createdAt),
                                  @"display_order" : VSelectorName(displayOrder)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    RKRelationshipMapping *userMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"created_by"
                                                                                        toKeyPath:VSelectorName(user)
                                                                                      withMapping:[VUser entityMapping]];
    [mapping addPropertyMapping:userMapping];
    
    return mapping;
}

+ (NSArray *)descriptors
{
    return @[
             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/api/notification/notifications_list"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/api/notification/notifications_list/:currentpage/:perpage"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             ];
}

@end
