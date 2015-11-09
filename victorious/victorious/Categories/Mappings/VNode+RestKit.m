//
//  Node+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VNode+RestKit.h"

#import "VAsset+RestKit.h"
#import "VInteraction+RestKit.h"

@implementation VNode (RestKit)

+ (NSString *)entityName
{
    return @"Node";
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"node_id" : VSelectorName(remoteId),
                                  @"share_url"      :   VSelectorName(shareUrlPath),
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    //Now add relationships
    [mapping addRelationshipMappingWithSourceKeyPath:VSelectorName(assets) mapping:[VAsset entityMapping]];
    [mapping addRelationshipMappingWithSourceKeyPath:VSelectorName(interactions) mapping:[VInteraction entityMapping]];
    
    return mapping;
}

@end
