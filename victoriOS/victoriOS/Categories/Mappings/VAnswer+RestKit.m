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
                                  @"answer_id" : VSelectorName(answerId),
                                  @"currency" : VSelectorName(currency),
                                  @"display_order" : VSelectorName(displayOrder),
                                  @"is_correct" : VSelectorName(isCorrect),
                                  @"label" : VSelectorName(label),
                                  @"points" : VSelectorName(points),
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(answerId) ];

    [mapping addAttributeMappingsFromDictionary:propertyMap];

    //Now add relationships
    [mapping addRelationshipMappingWithSourceKeyPath:VSelectorName(answerAction) mapping:[VAnswerAction entityMapping]];

    
    return mapping;
}

@end
