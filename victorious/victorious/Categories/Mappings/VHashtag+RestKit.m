//
//  VHashtag+RestKit.m
//  victorious
//
//  Created by Patrick Lynch on 10/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHashtag+RestKit.h"

@implementation VHashtag (RestKit)

+ (NSString *)entityName
{
    return @"Hashtag";
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"count"          : VSelectorName(count),
                                  @"tag"            : VSelectorName(tag)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(tag) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

+ (NSArray *)descriptors
{
    return @[ [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                        method:RKRequestMethodAny
                                                   pathPattern:@"/api/discover/hashtags"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]
              ];
}

@end
