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
    //This is equivilent to the above except it also checks for camelCase ect. versions of the keyPath
    [mapping addRelationshipMappingWithSourceKeyPath:@"nodes" mapping:[Node entityMapping]];
    [mapping addRelationshipMappingWithSourceKeyPath:@"comments" mapping:[Comment entityMapping]];
    
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
/*
+ (RKResponseDescriptor*)sequenceCommentDescriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[Sequence entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/comment/all/:sequence_id"
                                                       keyPath:@"payload"                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}*/
@end
