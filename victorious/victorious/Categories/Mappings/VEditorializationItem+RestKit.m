//
//  VEditorializationItem+RestKit.m
//  victorious
//
//  Created by Sharif Ahmed on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEditorializationItem+RestKit.h"

@implementation VEditorializationItem (RestKit)

+ (NSString *)entityName
{
    return @"EditorializationItem";
}

+ (NSDictionary *)attributePropertyMapping
{
    return @{ @"entry_label" : @"headline",
              @"stream_id" : @"streamId",
              @"id" : @"streamItemId",
              };
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = [self attributePropertyMapping];
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(streamItemId), VSelectorName(apiPath) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

@end
