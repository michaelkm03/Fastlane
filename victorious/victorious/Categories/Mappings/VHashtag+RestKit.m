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
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                           method:RKRequestMethodAny
                                                      pathPattern:@"/api/hashtag/subscribed_to_list/:page/:perpage"
                                                          keyPath:@"payload.tags"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                           method:RKRequestMethodAny
                                                      pathPattern:@"/api/hashtag/follow"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                           method:RKRequestMethodAny
                                                      pathPattern:@"/api/hashtag/unfollow"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]
              ];
}

@end
