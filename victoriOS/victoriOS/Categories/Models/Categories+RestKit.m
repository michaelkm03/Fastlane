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
    NSDictionary *propertyMap = @{
                                  @"name" : @"name"
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:NSStringFromClass([Categories class])
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ @"name" ];

    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"category"
                                                                            toKeyPath:@"category"
                                                                          withMapping:[VCategory entityMapping]]];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

+(RKResponseDescriptor*)descriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[Categories entityMapping]
                                                        method:RKRequestMethodPOST
                                                   pathPattern:nil
                                                       keyPath:@"payload"                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}
@end
