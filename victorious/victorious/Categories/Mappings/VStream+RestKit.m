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
    return @"Stream";
}

+ (NSDictionary *)propertyMap
{
    return @{
             @"id"                  :   VSelectorName(remoteId),
             @"stream_id"           :   VSelectorName(streamId),
             @"shelf_id"            :   VSelectorName(shelfId),
             @"stream_content_type" :   VSelectorName(streamContentType),
             @"name"                :   VSelectorName(name),
             @"preview_image"       :   VSelectorName(previewImagesObject),
             @"ugc_post_allowed"    :   VSelectorName(isUserPostAllowed),
             @"count"               :   VSelectorName(count),
             };
}

//This will map stream items from the "stream_items"-keyed array of streams inside each stream in the payload
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
                                                                                       withMapping:[[self class] streamItemMapping]];
    [mapping addPropertyMapping:sequenceMapping];

    return mapping;
}

//This will map from the top level
+ (RKEntityMapping *)payloadContentMapping
{
    NSDictionary *propertyMap = [[self class] propertyMap];
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    RKRelationshipMapping *marqueeMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"marquee"
                                                                                        toKeyPath:VSelectorName(marqueeItems)
                                                                                      withMapping:[[self class] listByStreamMapping]];
    [mapping addPropertyMapping:marqueeMapping];
    
    RKRelationshipMapping *contentMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"content"
                                                                                        toKeyPath:VSelectorName(streamItems)
                                                                                      withMapping:[[self class] listByStreamMapping]];
    [mapping addPropertyMapping:contentMapping];
    
    return mapping;
}

+ (RKEntityMapping *)basePayloadContentMapping
{
    NSDictionary *propertyMap = [[self class] propertyMap];
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    RKRelationshipMapping *contentMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"payload"
                                                                                        toKeyPath:VSelectorName(streamItems)
                                                                                      withMapping:[[self class] listByStreamMapping]];
    [mapping addPropertyMapping:contentMapping];
    
    return mapping;
}

+ (RKDynamicMapping *)streamItemMapping
{
    RKDynamicMapping *contentMapping = [RKDynamicMapping new];
    
    [contentMapping setObjectMappingForRepresentationBlock:^RKObjectMapping *(id representation)
     {
         if ( [[representation valueForKey:@"nodes"] isKindOfClass:[NSArray class]] )
         {
             return [VSequence entityMapping];
         }
         else
         {
             return [VStream childStreamMapping];
         }
     }];
    
    return contentMapping;
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
    //Many of these are not being used currently, but at risk of missing any, I've updated the restkit mapping to work with all versions of the detail_list_by_stream endpoint that were present in the VSequence descriptors
    return @[
             [RKResponseDescriptor responseDescriptorWithMapping:[self payloadContentMapping]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/api/sequence/detail_list_by_stream_with_marquee/:streamId/:page/:perpage"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self payloadContentMapping]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/api/sequence/detail_list_by_stream_with_marquee/:stream/:page/:perpage"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self payloadContentMapping]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/api/sequence/detail_list_by_stream_with_marquee/:streamId/:filterId/:page/:perpage"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self payloadContentMapping]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/api/sequence/detail_list_by_stream_with_marquee/:category/:filtername"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self payloadContentMapping]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/api/sequence/detail_list_by_category_with_marquee/:category"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self payloadContentMapping]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/api/sequence/detail_list_by_category_with_marquee/:category/:page/:perpage"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self payloadContentMapping]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/api/sequence/detail_list_by_hashtag_with_marquee/:hashtag/:page/:perpage"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self payloadContentMapping]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/api/sequence/gifs_by_sequence_with_marquee/:sequenceID/:page/:perpage"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self payloadContentMapping]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/api/sequence/memes_by_sequence_with_marquee/:sequenceID/:page/:perpage"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self payloadContentMapping]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/api/sequence/detail_list_by_liked/:page"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self basePayloadContentMapping]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/api/sequence/detail_list_by_user/:userid/:page/:perpage"
                                                         keyPath:@""
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]
              ];
}

@end
