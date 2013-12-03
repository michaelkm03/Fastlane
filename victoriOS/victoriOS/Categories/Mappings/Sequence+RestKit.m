//
//  Sequence+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/27/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VAppDelegate.h"
#import "Sequence+RestKit.h"

@implementation Sequence (RestKit)

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"category" : @"category",
                                  @"display_order" : @"display_order",
                                  @"id" : @"id",
                                  @"name" : @"name",
                                  @"preview_image" : @"preview_image",
                                  @"released_at" : @"released_at",
                                  @"sequence_description" : @"sequence_description",
                                  @"status" : @"status"
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:NSStringFromClass([Sequence class])
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ @"id" ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    //Now add relationships
    RKRelationshipMapping* nodeMapping = [RKRelationshipMapping
                                          relationshipMappingFromKeyPath:@"nodes"
                                          toKeyPath:@"nodes"
                                          withMapping:[Node entityMapping]];
    [mapping addPropertyMapping:nodeMapping];
    
    RKRelationshipMapping* commentMapping = [RKRelationshipMapping
                                             relationshipMappingFromKeyPath:@"comments"
                                             toKeyPath:@"comments"
                                             withMapping:[Node entityMapping]];
    [mapping addPropertyMapping:commentMapping];
    
    return mapping;
}

+ (RKResponseDescriptor*)sequenceListDescriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[Sequence entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/sequence/list_by_category/:category"
                                                       keyPath:@"payload"                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+ (RKResponseDescriptor*)sequenceFullDataDescriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[Sequence entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/sequence/item/:sequence_id"
                                                       keyPath:@"payload"                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+ (RKResponseDescriptor*)sequenceCommentDescriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[Sequence entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/comment/all/:sequence_id"
                                                       keyPath:@"payload"                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}
@end
