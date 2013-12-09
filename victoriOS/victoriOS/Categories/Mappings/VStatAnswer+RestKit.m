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
                                  @"answer_id" : @"answer_id",
                                  @"currency" : @"currency",
                                  @"id" : @"id",
                                  @"is_correct" : @"is_correct",
                                  @"label" : @"label"
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ @"id" ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

@end
