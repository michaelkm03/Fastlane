//
//  VStream+RestKit.m
//  victorious
//
//  Created by Will Long on 9/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStream+RestKit.h"

#import "VSequence+RestKit.h"

#import "VEditorializationItem.h"

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
             @"stream_content_type" :   VSelectorName(streamContentType),
             @"name"                :   VSelectorName(name),
             @"preview_image"       :   VSelectorName(previewImagesObject),
             @"ugc_post_allowed"    :   VSelectorName(isUserPostAllowed),
             @"count"               :   VSelectorName(count),
             };
}

+ (RKEntityMapping *)mappingBase
{
    NSDictionary *propertyMap = [VStream propertyMap];
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[VStream entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

//This will map stream items from the "stream_items"-keyed array of streams inside each stream in the payload
+ (RKEntityMapping *)entityMapping
{
    RKEntityMapping *mapping = [VStream mappingBase];
    
    RKRelationshipMapping *sequenceMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"stream_items"
                                                                                         toKeyPath:VSelectorName(streamItems)
                                                                                       withMapping:[[self class] streamItemMapping]];
    [mapping addPropertyMapping:sequenceMapping];
    
    [self addEditorializationConnectionToEntityMapping:mapping];
    
    return mapping;
}

//This will map from the top level
+ (RKEntityMapping *)payloadContentMapping
{
    RKEntityMapping *mapping = [VStream mappingBase];
    
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
    RKEntityMapping *mapping = [VStream mappingBase];
    
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
             return [self editorializedSequenceMapping];
         }
         else
         {
             return [self childStreamMapping];
         }
     }];
    
    return contentMapping;
}

+ (RKEntityMapping *)childStreamMapping
{
    return [self mappingBase];
}

+ (RKDynamicMapping *)listByStreamMapping
{
    RKDynamicMapping *contentMapping = [RKDynamicMapping new];
    
    [contentMapping addMatcher:[RKObjectMappingMatcher matcherWithPredicate:[NSPredicate predicateWithFormat:@"stream_content_type != nil"]
                                                              objectMapping:[VStream entityMapping]]];
    
    [contentMapping addMatcher:[RKObjectMappingMatcher matcherWithPredicate:[NSPredicate predicateWithFormat:@"stream_content_type == nil"]
                                                              objectMapping:[self editorializedSequenceMapping]]];
    
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
             
             [RKResponseDescriptor responseDescriptorWithMapping:[self basePayloadContentMapping]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/api/sequence/detail_list_by_user/:userid/:page/:perpage"
                                                         keyPath:@""
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              ];
}

#pragma mark - helpers

+ (void)addEditorializationConnectionToEntityMapping:(RKEntityMapping *)mapping
{
    [mapping addConnectionForRelationship:VSelectorName(editorialization) connectedBy:@{@"parentStreamId" : @"streamId", @"remoteId" : @"streamItemId"}];
}

+ (RKEntityMapping *)editorializedSequenceMapping
{
    RKEntityMapping *editorializedMapping = [VSequence entityMapping];
    [self addEditorializationConnectionToEntityMapping:editorializedMapping];
    return editorializedMapping;
}

@end
