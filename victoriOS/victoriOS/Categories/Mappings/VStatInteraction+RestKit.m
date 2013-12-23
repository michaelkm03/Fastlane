//
//  StatInteraction+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VStatInteraction+RestKit.h"

@implementation VStatInteraction (RestKit)

+ (NSString *)entityName
{
    return @"StatInteraction";
}

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"id" : VSelectorName(remoteId),
                                  @"interaction_id" : VSelectorName(interactionId),
                                  @"type" : VSelectorName(type),
                                  @"question" : VSelectorName(question),
                                  @"points" : VSelectorName(points),
                                  @"timeout" : VSelectorName(timeout),
                                  @"currency" : VSelectorName(currency),
                                  @"created_at" : VSelectorName(createdAt),
                                  @"updated_at" : VSelectorName(updatedAt),
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}


@end
