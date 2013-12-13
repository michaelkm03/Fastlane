//
//  StatAnswer+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VStatAnswer+RestKit.h"

@implementation VStatAnswer (RestKit)

+ (NSString *)entityName
{
    return @"StatAnswer";
}

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"answer_id" : VSelectorName(answerId),
                                  @"currency" : VSelectorName(currency),
                                  @"id" : VSelectorName(statAnswerId),
                                  @"is_correct" : VSelectorName(isCorrect),
                                  @"label" : VSelectorName(label)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(statAnswerId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

@end
