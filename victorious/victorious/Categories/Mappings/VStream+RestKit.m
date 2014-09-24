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
                                  @"preview_images"  :   VSelectorName(previewImagesObject),
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
        
    RKDynamicMapping *contentMapping = [RKDynamicMapping new];
    RKObjectMapping *sequenceMapping = [VSequence entityMapping];
    
    [contentMapping addMatcher:[RKObjectMappingMatcher matcherWithKeyPath:@"stream_content_type"
                                                     expectedValue:@"stream"
                                                     objectMapping:mapping]];
    
    [contentMapping addMatcher:[RKObjectMappingMatcher matcherWithKeyPath:@"stream_content_type"
                                                     expectedValue:@"sequence"
                                                     objectMapping:sequenceMapping]];
    
    RKRelationshipMapping *contentRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"content"
                                                                                           toKeyPath:VSelectorName(streamItems)
                                                                                         withMapping:contentMapping];
    [mapping addPropertyMapping:contentRelationshipMapping];
    
    return mapping;
}

+ (NSArray *)descriptors
{
    return @[ [RKResponseDescriptor responseDescriptorWithMapping:[VStream entityMapping]
                                                           method:RKRequestMethodGET
                                                      pathPattern:@"/api/sequence/detail_list_by_stream/:streamId/:page/:perpage"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              ];
}

@end
