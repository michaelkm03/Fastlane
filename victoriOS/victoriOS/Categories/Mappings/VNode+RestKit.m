//
//  Node+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VNode+RestKit.h"

@implementation VNode (RestKit)

+ (NSString *)entityName
{
    return @"Node";
}

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"display_order" : @"display_order",
                                  @"node_id" : @"node_id"
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ @"node_id" ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    //Now add relationships
    [mapping addRelationshipMappingWithSourceKeyPath:@"assets" mapping:[VAsset entityMapping]];
    [mapping addRelationshipMappingWithSourceKeyPath:@"interactions" mapping:[VInteraction entityMapping]];
    [mapping addRelationshipMappingWithSourceKeyPath:@"node_action" mapping:[VNodeAction entityMapping]];
    
    return mapping;
}

@end
