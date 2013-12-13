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
                                  @"answered_at" : VSelectorName(answeredAt),
                                  @"currency" : VSelectorName(currency),
                                  @"id" : VSelectorName(statInteractionId),
                                  @"interaction_id" : VSelectorName(interactionId),
                                  @"points" : VSelectorName(points),
                                  @"question" : VSelectorName(question),
                                  @"type" : VSelectorName(type)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(statInteractionId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}


@end
