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
                                  @"notify_type" : VSelectorName(notifyType),
                                  @"posted_at" : VSelectorName(postedAt),
                                  @"id" : VSelectorName(remoteId),
                                  @"subject" : VSelectorName(subject),
                                  @"user_id" : VSelectorName(userId),
                                  @"creator_profile_image_url" : VSelectorName(imageURL),
                                  @"created_at" : VSelectorName(createdAt),
                                  @"user" : VSelectorName(user),
                                  @"message" : VSelectorName(message),
                                  @"comment" : VSelectorName(comment)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    [mapping addConnectionForRelationship:@"user" connectedBy:@{@"userId" : @"remoteId"}];
    
    return mapping;
}

+ (NSArray *)descriptors
{
    return @[ [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                           method:RKRequestMethodGET
                                                      pathPattern:@"/api/notification/notifications_list"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                           method:RKRequestMethodGET
                                                      pathPattern:@"/api/notification/notifications_list/:currentpage/:perpage"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              /*
              [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                           method:RKRequestMethodGET
                                                      pathPattern:@"/api/notification/notifications_for_user/:userid/:currentpage/:perpage"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                           method:RKRequestMethodGET
                                                      pathPattern:@"/api/message/notifications_for_user/:userid"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]
               */
              ];
}

@end
