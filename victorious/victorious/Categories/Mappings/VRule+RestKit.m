//
//  Rule+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VRule+RestKit.h"

@implementation VRule (RestKit)

+ (NSString *)entityName
{
    return @"Rule";
}

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"name" : VSelectorName(name)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(name) ];

    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

@end
