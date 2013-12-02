//
//  AnswerAction+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "AnswerAction+RestKit.h"

@implementation AnswerAction (RestKit)

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"goto_node" : @"goto_node"
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:NSStringFromClass([AnswerAction class])
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

@end
