//
//  VVoteResult+RestKit.m
//  victorious
//
//  Created by Will Long on 4/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVoteResult+RestKit.h"

@implementation VVoteResult (RestKit)
+ (NSString *)entityName
{
    return @"VoteResult";
}

+ (RKEntityMapping*)entityMapping
{
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
//    mapping.forceCollectionMapping = YES;
    
    [mapping addAttributeMappingFromKeyOfRepresentationToAttribute:VSelectorName(remoteId)];
    
    RKAttributeMapping* idMapping = [RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:VSelectorName(remoteId)];
    [mapping addPropertyMapping:idMapping];
    
    [mapping addAttributeMappingsFromDictionary:@{ @"(remoteId)"  : VSelectorName(count) }];
//    [mapping addAttributeMappingToKeyOfRepresentationFromAttribute:VSelectorName(count)];

    return mapping;
}

@end
