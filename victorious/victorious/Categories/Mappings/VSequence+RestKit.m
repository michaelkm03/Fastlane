//
//  Sequence+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/27/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
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
                                  @"category" : VSelectorName(category),
                                  // for some reason this cannot be camelCase...
                                  @"display_order" : VSelectorName(display_order),
                                  @"id" : VSelectorName(remoteId),
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
    return [RKResponseDescriptor responseDescriptorWithMapping:[VSequence entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/sequence/detail_list_by_category/:category/:status/:page/:perpage"
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
