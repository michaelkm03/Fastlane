//
//  Asset+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VAsset+RestKit.h"

@implementation VAsset (RestKit)

+ (NSString *)entityName
{
    return @"Asset";
}

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"node_id" : VSelectorName(nodeId),
                                  @"display_order" : VSelectorName(display_order),
                                  @"type" : VSelectorName(type),
                                  @"data" : VSelectorName(data),
                                  @"rate" : VSelectorName(rate),
                                  @"loop" : VSelectorName(loop),
                                  @"asset_id" : VSelectorName(remoteId)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(display_order), VSelectorName(nodeId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];

    [mapping addConnectionForRelationship:@"comments" connectedBy:@{@"remoteId" : @"assetId"}];
    
    return mapping;
}

+ (RKEntityMapping*)entityMappingForVVoteType
{

    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [mapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"@metadata.mapping.collectionIndex"
                                                                      toKeyPath:VSelectorName(display_order)]];
    [mapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:VSelectorName(data)]];
    
    return mapping;
}

@end
