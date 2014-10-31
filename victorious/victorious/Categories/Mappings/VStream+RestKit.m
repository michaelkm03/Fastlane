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

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"id"             :   VSelectorName(remoteId),
                                  @"stream_content_type"     :   VSelectorName(streamContentType),
                                  @"name"           :   VSelectorName(name),
                                  @"preview_image"  :   VSelectorName(previewImagesObject),
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

+ (RKDynamicMapping *)listByStreamMapping
{
    RKDynamicMapping *contentMapping = [RKDynamicMapping new];
    RKObjectMapping *sequenceMapping = [VSequence entityMapping];
    
    [contentMapping addMatcher:[RKObjectMappingMatcher matcherWithPredicate:[NSPredicate predicateWithFormat:@"streamContentType == content"]
                                                              objectMapping:[self entityMapping]]];
    
    [contentMapping addMatcher:[RKObjectMappingMatcher matcherWithPredicate:[NSPredicate predicateWithFormat:@"streamContentType != content"]
                                                              objectMapping:sequenceMapping]];
    
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
