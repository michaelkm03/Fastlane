//
//  VUnreadConversation+RestKit.m
//  victorious
//
//  Created by Will Long on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUnreadConversation+RestKit.h"

@implementation VUnreadConversation (RestKit)

+ (NSString *)entityName
{
    return @"UnreadConversation";
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"unread_count" : VSelectorName(count)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

+ (RKResponseDescriptor *)descriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/message/unread_message_count"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

@end
