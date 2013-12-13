//
//  User+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/27/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
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
                                  @"access_level" : VSelectorName(accessLevel),
                                  @"email" : VSelectorName(email),
                                  @"id" : VSelectorName(userId),
                                  @"name" : VSelectorName(name),
                                  @"token" : VSelectorName(token),
                                  @"token_updated_at" : VSelectorName(tokenUpdatedAt)
                                  };

    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];

    mapping.identificationAttributes = @[ VSelectorName(userId) ];

    [mapping addAttributeMappingsFromDictionary:propertyMap];

    return mapping;
}

+ (RKResponseDescriptor*)descriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                        method:RKRequestMethodPOST
                                                   pathPattern:nil
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}
@end