//
//  VImageAsset+RestKit.m
//  victorious
//
//  Created by Patrick Lynch on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageAsset+RestKit.h"

@implementation VImageAsset (RestKit)

+ (NSString *)entityName
{
    return @"ImageAsset";
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{ @"imageURL": VSelectorName(imageURL),
                                   @"type": VSelectorName(type),
                                   @"width": VSelectorName(width),
                                   @"height": VSelectorName(height) };
    
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:[self entityName]
                                                   inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(imageURL) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    return mapping;
}

@end
