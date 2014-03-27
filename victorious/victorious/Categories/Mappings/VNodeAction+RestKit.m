//
//  NodeAction+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VNodeAction+RestKit.h"

@implementation VNodeAction (RestKit)

+ (NSString *)entityName
{
    return @"NodeAction";
}

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"won_goto_node" : VSelectorName(wonGotoNode),
                                  @"lost_goto_node" : VSelectorName(lostGotoNode)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

@end
