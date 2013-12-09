//
//  StatInteraction+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VStatInteraction+RestKit.h"

@implementation VStatInteraction (RestKit)

+ (NSString *)entityName
{
    return @"StatInteraction";
}

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"answered_at" : @"answered_at",
                                  @"currency" : @"currency",
                                  @"id" : @"id",
                                  @"interaction_id" : @"interaction_id",
                                  @"points" : @"points",
                                  @"question" : @"question",
                                  @"type" : @"type"
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ @"id" ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}


@end
