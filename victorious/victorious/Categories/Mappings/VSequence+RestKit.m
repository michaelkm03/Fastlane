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
#import "VUser+RestKit.h"
#import "VTracking+RestKit.h"
#import "VAdBreak+RestKit.h"

@implementation VSequence (RestKit)

+ (NSString *)entityName
{
    return @"Sequence";
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"category"       :   VSelectorName(category),
                                  @"id"             :   VSelectorName(remoteId),
                                  @"created_by"     :   VSelectorName(createdBy),
                                  @"name"           :   VSelectorName(name),
                                  @"preview_image"  :   VSelectorName(previewImagesObject),
                                  @"released_at"    :   VSelectorName(releasedAt),
                                  @"description"    :   VSelectorName(sequenceDescription),
                                  @"status"         :   VSelectorName(status),
                                  @"is_complete"    :   VSelectorName(isComplete),
                                  @"is_remix"       :   VSelectorName(isRemix),
                                  @"is_repost"      :   VSelectorName(isRepost),
                                  @"game_status"    :   VSelectorName(gameStatus),
                                  @"permissions"    :   VSelectorName(permissions),
                                  @"parent_user_id" :   VSelectorName(parentUserId),
                                  @"name_embedded_in_content"   : VSelectorName(nameEmbeddedInContent),
                                  @"sequence_counts.comments"   : VSelectorName(commentCount),
                                  @"sequence_counts.remixes"    : VSelectorName(remixCount),
                                  @"sequence_counts.reposts"    : VSelectorName(repostCount),
                                  @"preview.type"           : VSelectorName(previewType),
                                  @"preview.data"           : VSelectorName(previewData)
                                  };

    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    [mapping addRelationshipMappingWithSourceKeyPath:VSelectorName(nodes) mapping:[VNode entityMapping]];
    [mapping addRelationshipMappingWithSourceKeyPath:VSelectorName(comments) mapping:[VComment entityMapping]];
    [mapping addRelationshipMappingWithSourceKeyPath:VSelectorName(user) mapping:[VUser entityMapping]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"parent_user"
                                                                            toKeyPath:@"parentUser"
                                                                          withMapping:[VUser entityMapping]]];
    
    RKRelationshipMapping *voteResultMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"sequence_counts.votetypes"
                                                                                           toKeyPath:VSelectorName(voteResults)
                                                                                         withMapping:[VVoteResult entityMapping]];
    
    RKRelationshipMapping *adBreaksMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"ad_breaks"
                                                                                           toKeyPath:VSelectorName(adBreaks)
                                                                                         withMapping:[VAdBreak entityMapping]];
    [mapping addPropertyMapping:voteResultMapping];
    [mapping addPropertyMapping:adBreaksMapping];
    
    RKRelationshipMapping *trackingMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"tracking"
                                                                                          toKeyPath:VSelectorName(tracking)
                                                                                        withMapping:[VTracking entityMapping]];
    [mapping addPropertyMapping:trackingMapping];
    
    [mapping addConnectionForRelationship:@"comments" connectedBy:@{@"remoteId" : @"sequenceId"}];
    
    return mapping;
}

+ (NSArray *)descriptors
{
    return @[ [RKResponseDescriptor responseDescriptorWithMapping:[VSequence entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/sequence/detail_list_by_category/:category"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
            
              [RKResponseDescriptor responseDescriptorWithMapping:[VSequence entityMapping]
                                                           method:RKRequestMethodGET
                                                      pathPattern:@"/api/sequence/detail_list_by_user/:userid/:page/:perpage"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
          
              [RKResponseDescriptor responseDescriptorWithMapping:[VSequence entityMapping]
                                                           method:RKRequestMethodGET
                                                      pathPattern:@"/api/sequence/detail_list_by_category/:category/:page/:perpage"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              [RKResponseDescriptor responseDescriptorWithMapping:[VSequence entityMapping]
                                                           method:RKRequestMethodGET
                                                      pathPattern:@"/api/sequence/hot_detail_list_by_stream/:stream/:page/:perpage"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],

              [RKResponseDescriptor responseDescriptorWithMapping:[VSequence entityMapping]
                                                           method:RKRequestMethodGET
                                                      pathPattern:@"/api/sequence/detail_list_by_hashtag/:hashtag/:page/:perpage"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              [RKResponseDescriptor responseDescriptorWithMapping:[VSequence entityMapping]
                                                           method:RKRequestMethodGET
                                                      pathPattern:@"/api/sequence/follows_detail_list_by_stream/:userid/:stream/:page/:perpage"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              [RKResponseDescriptor responseDescriptorWithMapping:[VSequence entityMapping]
                                                           method:RKRequestMethodGET
                                                      pathPattern:@"/api/sequence/remixes_by_sequence/:sequenceID/:page/:perpage"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              [RKResponseDescriptor responseDescriptorWithMapping:[VSequence entityMapping]
                                                           method:RKRequestMethodGET
                                                      pathPattern:@"/api/sequence/fetch/:sequence_id"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]
              ];
}

@end
