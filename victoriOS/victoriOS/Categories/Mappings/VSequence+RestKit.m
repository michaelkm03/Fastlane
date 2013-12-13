//
//  Sequence+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/27/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VAppDelegate.h"
#import "VSequence+RestKit.h"

@implementation VSequence (RestKit)

+ (NSString *)entityName
{
    return @"Sequence";
}

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
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ @"id" ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    //Now add relationships
    //This is equivilent to the above except it also checks for camelCase ect. versions of the keyPath
    [mapping addRelationshipMappingWithSourceKeyPath:@"nodes" mapping:[VNode entityMapping]];
    [mapping addRelationshipMappingWithSourceKeyPath:@"comments" mapping:[VComment entityMapping]];
    
    return mapping;
}

+ (RKResponseDescriptor*)sequenceListDescriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[VSequence entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/sequence/list_by_category/:category"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+ (RKResponseDescriptor*)sequenceFullDataDescriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[VSequence entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/sequence/fetch/:sequence_id"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

@end
