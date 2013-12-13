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
                                  @"id" : VSelectorName(remoteId),
                                  @"answer_id" : VSelectorName(answerId),
                                  @"label" : VSelectorName(label),
                                  @"is_correct" : VSelectorName(isCorrect),
                                  @"currency" : VSelectorName(currency),
                                  @"answered_at" : VSelectorName(answeredAt),
                                  @"created_at" : VSelectorName(createdAt),
                                  @"updated_at" : VSelectorName(updatedAt)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

@end
