//
//  Answer+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "Answer+RestKit.h"

@implementation Answer (RestKit)

+(RKEntityMapping*)entityMapping
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
                                mappingForEntityForName:NSStringFromClass([Answer class])
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ @"answer_id" ];

    [mapping addAttributeMappingsFromDictionary:propertyMap];

    //Now add relationships
    RKRelationshipMapping* actionMapping = [RKRelationshipMapping
                                            relationshipMappingFromKeyPath:@"answer_action"
                                            toKeyPath:@"answer_action"
                                            withMapping:[AnswerAction entityMapping]];
    [mapping addPropertyMapping:actionMapping];
    
    return mapping;
}

@end
