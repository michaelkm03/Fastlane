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
                                  @"display_order" : @"display_order",
                                  @"interaction_id" : @"interaction_id",
                                  @"node_id" : @"node_id",
                                  @"question" : @"question",
                                  @"start_time" : @"start_time",
                                  @"type" : @"type"
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ @"interaction_id" ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    [mapping addRelationshipMappingWithSourceKeyPath:@"interaction_action" mapping:[VInteractionAction entityMapping]];
    [mapping addRelationshipMappingWithSourceKeyPath:@"rules" mapping:[VRule entityMapping]];
    [mapping addRelationshipMappingWithSourceKeyPath:@"answers" mapping:[VAnswer entityMapping]];

    return mapping;
}

@end
