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

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                          @"access_level" : @"access_level",
                                          @"email" : @"email",
                                          @"id" : @"id",
                                          @"name" : @"name",
                                          @"token" : @"token",
                                          @"token_updated_at" : @"token_updated_at"
                                          };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                        mappingForEntityForName:[self entityName]
                                        inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ @"id" ];
    
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