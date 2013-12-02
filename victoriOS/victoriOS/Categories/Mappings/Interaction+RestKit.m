//
//  Interaction+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "Interaction+RestKit.h"
#import "Rule+RestKit.h"
#import "InteractionAction+RestKit.h"
#import "Answer+RestKit.h"

@implementation Interaction (RestKit)

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"display_order" : @"display_order",
                                  @"interaction_id" : @"interaction_id",
                                  @"node_id" : @"node_id",
                                  @"question" : @"question",
                                  @"start_time" : @"start_time",
                                  @"type" : @"type"
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:NSStringFromClass([Interaction class])
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ @"interaction_id" ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    //Now add relationships
    RKRelationshipMapping* answerMapping = [RKRelationshipMapping
                                           relationshipMappingFromKeyPath:@"answers"
                                           toKeyPath:@"answers"
                                           withMapping:[Answer entityMapping]];
    [mapping addPropertyMapping:answerMapping];
    
    RKRelationshipMapping* ruleMapping = [RKRelationshipMapping
                                                  relationshipMappingFromKeyPath:@"rules"
                                                  toKeyPath:@"rules"
                                                  withMapping:[Rule entityMapping]];
    [mapping addPropertyMapping:ruleMapping];
    
    RKRelationshipMapping* actionMapping = [RKRelationshipMapping
                                            relationshipMappingFromKeyPath:@"interaction_action"
                                            toKeyPath:@"interaction_action"
                                            withMapping:[InteractionAction entityMapping]];
    [mapping addPropertyMapping:actionMapping];
    
    return mapping;
}

@end
