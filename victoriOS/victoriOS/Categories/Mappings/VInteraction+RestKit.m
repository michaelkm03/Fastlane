//
//  Interaction+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VInteraction+RestKit.h"
#import "VRule+RestKit.h"
#import "VInteractionAction+RestKit.h"
#import "VAnswer+RestKit.h"

@implementation VInteraction (RestKit)

+ (NSString *)entityName
{
    return @"Interaction";
}

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"node_id" : VSelectorName(nodeId),
                                  @"display_order" : VSelectorName(displayOrder),
                                  @"start_time" : VSelectorName(startTime),
                                  @"type" : VSelectorName(type),
                                  @"interaction_id" : VSelectorName(remoteId),
                                  @"question" : VSelectorName(question),
                                  @"timeout" : VSelectorName(timeout)
                                  };

    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];

    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];

    [mapping addAttributeMappingsFromDictionary:propertyMap];

    [mapping addRelationshipMappingWithSourceKeyPath:VSelectorName(interactionAction) mapping:[VInteractionAction entityMapping]];
    [mapping addRelationshipMappingWithSourceKeyPath:VSelectorName(rules) mapping:[VRule entityMapping]];
    [mapping addRelationshipMappingWithSourceKeyPath:VSelectorName(answer) mapping:[VAnswer entityMapping]];

    return mapping;
}

@end
