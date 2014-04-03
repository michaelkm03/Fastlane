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
#import "VVoteResult+RestKit.h"

@implementation VSequence (RestKit)

+ (NSString *)entityName
{
    return @"Sequence";
}

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"category"       :   VSelectorName(category),
                                  // for some reason this cannot be camelCase...
                                  @"display_order"  : 	VSelectorName(display_order),
                                  @"id"             :   VSelectorName(remoteId),
                                  @"created_by"     :   VSelectorName(createdBy),
                                  @"name"           :   VSelectorName(name),
                                  @"preview_image"  :   VSelectorName(previewImage),
                                  @"released_at"    :   VSelectorName(releasedAt),
                                  @"description"    :   VSelectorName(sequenceDescription),
                                  @"status"         :   VSelectorName(status),
                                  @"is_complete"    :   VSelectorName(isComplete),
                                  @"game_status"    :   VSelectorName(gameStatus),
                                  @"expires_at"     :   VSelectorName(expiresAt),
                                  @"sequence_counts.comment"    : VSelectorName(commentCount),
                                  @"sequence_counts.remix"      : VSelectorName(remixCount)
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
    
    mapping.forceCollectionMapping = YES;
    RKRelationshipMapping* voteResultMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"sequence_counts.votetype"
                                                                                           toKeyPath:VSelectorName(voteResults)
                                                                                         withMapping:[VVoteResult entityMapping]];
    [mapping addPropertyMapping:voteResultMapping];
//    [mapping addRelationshipMappingWithSourceKeyPath:VSelectorName(voteResults) mapping:[VVoteResult entityMapping]];
    
    
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

+ (RKResponseDescriptor*)sequenceListByUserDescriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[VSequence entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/sequence/detail_list_by_user/:userid/:page/:perpage"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+ (RKResponseDescriptor*)sequenceListPaginationDescriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[VSequence entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/sequence/detail_list_by_category/:category/:page/:perpage"
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
