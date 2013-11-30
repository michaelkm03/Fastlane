//
//  Categories+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/29/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "Categories+RestKit.h"
#import "VCategory+RestKit.h"

@implementation Categories (RestKit)


+(RKEntityMapping*)entityMapping
{
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:NSStringFromClass([Categories class])
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    RKRelationshipMapping* relationMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"" toKeyPath:@"categories" withMapping:[VCategory entityMapping]];
    
    [mapping addPropertyMapping:relationMapping];
    
    return mapping;
}

+(RKResponseDescriptor*)descriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[Categories entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:nil
                                                       keyPath:@"payload"                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

@end
