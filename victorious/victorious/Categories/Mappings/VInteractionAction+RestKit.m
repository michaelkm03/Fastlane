//
//  InteractionAction+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VInteractionAction+RestKit.h"

@implementation VInteractionAction (RestKit)

+ (NSString *)entityName
{
    return @"InteractionAction";
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"correct_goto_node" : VSelectorName(correctGotoNode),
                                  @"incorrect_goto_node" : VSelectorName(incorrectGotoNode),
                                  @"timeout_goto_node" : VSelectorName(timeoutGotoNode)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

@end
