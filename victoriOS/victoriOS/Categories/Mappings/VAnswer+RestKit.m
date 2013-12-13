//
//  Answer+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VAnswer+RestKit.h"

@implementation VAnswer (RestKit)

+ (NSString *)entityName
{
    return @"Answer";
}

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"answer_id" : @"answer_id",
                                  @"currency" : @"currency",
                                  @"display_order" : @"display_order",
                                  @"is_correct" : @"is_correct",
                                  @"label" : @"label",
                                  @"points" : @"points"
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ @"answer_id" ];

    [mapping addAttributeMappingsFromDictionary:propertyMap];

    //Now add relationships
    [mapping addRelationshipMappingWithSourceKeyPath:@"answer_action" mapping:[VAnswerAction entityMapping]];

    
    return mapping;
}

@end
