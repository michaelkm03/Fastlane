//
//  StatInteraction+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "StatInteraction+RestKit.h"

@implementation StatInteraction (RestKit)

+(RKEntityMapping*)entityMapping
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
                                mappingForEntityForName:NSStringFromClass([StatInteraction class])
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ @"interaction_id" ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}


@end
