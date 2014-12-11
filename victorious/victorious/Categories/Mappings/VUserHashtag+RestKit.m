//
//  VUserHashtag+RestKit.m
//  victorious
//
//  Created by Lawrence Leach on 12/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUserHashtag+RestKit.h"

@implementation VUserHashtag (RestKit)

+ (NSString *)entityName
{
    return @"UserHashtag";
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"tag" : VSelectorName(tag)
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
                                                      pathPattern:@"/api/hashtag/subscribe_to_list"
                                                          keyPath:@"payload"
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
