//
//  InteractionAction+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "InteractionAction+RestKit.h"

@implementation InteractionAction (RestKit)

+(RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"correct_goto_node" : @"correct_goto_node",
                                  @"incorrect_goto_node" : @"incorrect_goto_node",
                                  @"timeout_goto_node" : @"timeout_goto_node"
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:NSStringFromClass([InteractionAction class])
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

@end
