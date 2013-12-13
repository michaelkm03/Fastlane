//
//  Asset+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
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
                                  @"display_order" : VSelectorName(displayOrder),
                                  @"type" : VSelectorName(type),
                                  @"data" : VSelectorName(data)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(displayOrder), VSelectorName(nodeId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

@end
