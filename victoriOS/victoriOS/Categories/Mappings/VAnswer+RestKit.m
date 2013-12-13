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
                                  @"label" : VSelectorName(label),
                                  @"display_order" : VSelectorName(displayOrder),
                                  @"answer_id" : VSelectorName(remoteId),
                                  @"is_correct" : VSelectorName(isCorrect),
                                  @"points" : VSelectorName(points),
                                  @"currency" : VSelectorName(currency)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];

    [mapping addAttributeMappingsFromDictionary:propertyMap];

    //Now add relationships
    [mapping addRelationshipMappingWithSourceKeyPath:VSelectorName(answerAction) mapping:[VAnswerAction entityMapping]];

    
    return mapping;
}

@end
