//
//  VStream+RestKit.m
//  victorious
//
//  Created by Will Long on 9/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStream+RestKit.h"

#import "VSequence+RestKit.h"

@implementation VStream (RestKit)

+ (NSString *)entityName
{
    return @"VStream";
}

+ (NSDictionary *)propertyMap
{
    return @{
             @"id"                  :   VSelectorName(remoteId),
             @"stream_content_type" :   VSelectorName(streamContentType),
             @"name"                :   VSelectorName(name),
             @"preview_image"       :   VSelectorName(previewImagesObject),
             @"count"               :   VSelectorName(count),
             };
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = [[self class] propertyMap];
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    RKRelationshipMapping *sequenceMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"stream_items"
                                                                                         toKeyPath:VSelectorName(streamItems)
                                                                                       withMapping:[[self class] childStreamMapping]];
    [mapping addPropertyMapping:sequenceMapping];
    
    return mapping;
}

+ (RKEntityMapping *)childStreamMapping
{
    NSDictionary *propertyMap = [[self class] propertyMap];
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:[VStream entityName]
                                                   inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    return mapping;
}

+ (RKDynamicMapping *)listByStreamMapping
{
    RKDynamicMapping *contentMapping = [RKDynamicMapping new];

    [contentMapping addMatcher:[RKObjectMappingMatcher matcherWithPredicate:[NSPredicate predicateWithFormat:@"stream_content_type != nil"]
                                                              objectMapping:[VStream entityMapping]]];
    
    [contentMapping addMatcher:[RKObjectMappingMatcher matcherWithPredicate:[NSPredicate predicateWithFormat:@"stream_content_type == nil"]
                                                              objectMapping:[VSequence entityMapping]]];
    
    return contentMapping;
}

+ (NSArray *)descriptors
{
    return @[
             [RKResponseDescriptor responseDescriptorWithMapping:[self listByStreamMapping]
                                                           method:RKRequestMethodGET
                                                      pathPattern:@"/api/sequence/detail_list_by_stream/:streamId/:page/:perpage"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self listByStreamMapping]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/api/sequence/detail_list_by_stream/:streamId/:filterId/:page/:perpage"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              ];
}

@end
