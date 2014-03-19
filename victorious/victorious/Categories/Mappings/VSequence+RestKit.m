//
//  Sequence+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/27/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VSequence+RestKit.h"
#import "VComment+RestKit.h"
#import "VNode+RestKit.h"

@implementation VSequence (RestKit)

+ (NSString *)entityName
{
    return @"Sequence";
}

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"category" : VSelectorName(category),
                                  // for some reason this cannot be camelCase...
                                  @"display_order" : VSelectorName(display_order),
                                  @"id" : VSelectorName(remoteId),
                                  @"created_by" : VSelectorName(createdBy),
                                  @"name" : VSelectorName(name),
                                  @"preview_image" : VSelectorName(previewImage),
                                  @"released_at" : VSelectorName(releasedAt),
                                  @"description" : VSelectorName(sequenceDescription),
                                  @"status" : VSelectorName(status),
                                  @"is_complete": VSelectorName(isComplete),
                                  @"game_status": VSelectorName(gameStatus),
                                  };

    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    //Now add relationships
    //This is equivilent to the above except it also checks for camelCase ect. versions of the keyPath
    [mapping addRelationshipMappingWithSourceKeyPath:VSelectorName(nodes) mapping:[VNode entityMapping]];
    [mapping addRelationshipMappingWithSourceKeyPath:VSelectorName(comments) mapping:[VComment entityMapping]];
    
    [mapping addConnectionForRelationship:@"user" connectedBy:@{@"createdBy" : @"remoteId"}];
    [mapping addConnectionForRelationship:@"comments" connectedBy:@{@"remoteId" : @"sequenceId"}];

    return mapping;
}

+ (RKResponseDescriptor*)sequenceListDescriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[VSequence entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/sequence/detail_list_by_category/:category"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+ (RKResponseDescriptor*)sequenceListPaginationDescriptor
{
#ifdef STABLE_DEBUG
    return [RKResponseDescriptor responseDescriptorWithMapping:[VSequence entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/sequence/detail_list_by_category/:status/:category/:page/:perpage"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
#elif DEBUG
    return [RKResponseDescriptor responseDescriptorWithMapping:[VSequence entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/sequence/detail_list_by_category/:category/:page/:perpage"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
#else
    return [RKResponseDescriptor responseDescriptorWithMapping:[VSequence entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/sequence/detail_list_by_category/:status/:category/:page/:perpage"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
#endif
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
