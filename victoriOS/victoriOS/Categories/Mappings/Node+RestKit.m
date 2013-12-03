//
//  Node+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "Node+RestKit.h"

@implementation Node (RestKit)

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"display_order" : @"display_order",
                                  @"node_id" : @"node_id"
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:NSStringFromClass([Node class])
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ @"node_id" ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    //Now add relationships
    [mapping addRelationshipMappingWithSourceKeyPath:@"assets" mapping:[Asset entityMapping]];
    [mapping addRelationshipMappingWithSourceKeyPath:@"interactions" mapping:[Interaction entityMapping]];
    [mapping addRelationshipMappingWithSourceKeyPath:@"node_action" mapping:[NodeAction entityMapping]];
    
    return mapping;
}

@end
