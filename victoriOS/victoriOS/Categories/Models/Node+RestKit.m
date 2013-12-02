//
//  Node+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "Node+RestKit.h"

@implementation Node (RestKit)

+(RKEntityMapping*)entityMapping
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
    RKRelationshipMapping* assetMapping = [RKRelationshipMapping
                                          relationshipMappingFromKeyPath:@"assets"
                                          toKeyPath:@"assets"
                                          withMapping:[Asset entityMapping]];
    [mapping addPropertyMapping:assetMapping];
    
    RKRelationshipMapping* interactionsMapping = [RKRelationshipMapping
                                          relationshipMappingFromKeyPath:@"interactions"
                                          toKeyPath:@"interactions"
                                          withMapping:[Interaction entityMapping]];
    [mapping addPropertyMapping:interactionsMapping];
    
    RKRelationshipMapping* actionMapping = [RKRelationshipMapping
                                          relationshipMappingFromKeyPath:@"node_action"
                                          toKeyPath:@"node_action"
                                          withMapping:[NodeAction entityMapping]];
    [mapping addPropertyMapping:actionMapping];
    
    return mapping;
}

@end
