//
//  Sequence+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/27/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VObjectManager.h"
#import "VSequence+RestKit.h"
#import "VAsset+RestKit.h"
#import "VComment+RestKit.h"
#import "VNode+RestKit.h"
#import "VVoteResult+RestKit.h"
#import "VUser+RestKit.h"
#import "VTracking+RestKit.h"
#import "VAdBreak+RestKit.h"
#import "VStream+RestKit.h"
#import "VImageAsset+RestKit.h"
#import "VEditorializationItem.h"

@implementation VSequence (RestKit)

+ (NSString *)entityName
{
    return @"Sequence";
}

+ (NSDictionary *)attributePropertyMapping
{
    return @{ @"category"       :   VSelectorName(category),
              @"id"             :   VSelectorName(remoteId),
              @"created_by"     :   VSelectorName(createdBy),
              @"entry_label"    :   VSelectorName(headline),
              @"name"           :   VSelectorName(name),
              @"preview_image"  :   VSelectorName(previewImagesObject),
              @"released_at"    :   VSelectorName(releasedAt),
              @"description"    :   VSelectorName(sequenceDescription),
              @"stream_id"      :   VSelectorName(streamId),
              @"is_complete"    :   VSelectorName(isComplete),
              @"is_remix"       :   VSelectorName(isRemix),
              @"is_repost"      :   VSelectorName(isRepost),
              @"am_liking"      :   VSelectorName(isLikedByMainUser),
              @"game_status"    :   VSelectorName(gameStatus),
              @"permissions"    :   VSelectorName(permissionsMask),
              @"name_embedded_in_content"   : VSelectorName(nameEmbeddedInContent),
              @"sequence_counts.comments"   : VSelectorName(commentCount),
              @"sequence_counts.gifs"   : VSelectorName(gifCount),
              @"sequence_counts.memes"  :   VSelectorName(memeCount),
              @"sequence_counts.reposts"    : VSelectorName(repostCount),
              @"sequence_counts.likes"    : VSelectorName(likeCount),
              @"preview.type"           : VSelectorName(previewType),
              @"preview.data"           : VSelectorName(previewData),
              @"stream_content_type" :   VSelectorName(streamContentType),
              @"has_reposted"   :   VSelectorName(hasReposted),
              @"is_gif_style"   :   VSelectorName(isGifStyle),
              @"type"                :   VSelectorName(itemType),
              @"subtype"             :   VSelectorName(itemSubType),
              @"trending_topic_name" : VSelectorName(trendingTopicName)
    };
}

+ (RKEntityMapping *)mappingBase
{
    NSDictionary *propertyMap = [VSequence attributePropertyMapping];
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[VSequence entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

+ (RKEntityMapping *)simpleMapping
{
    static NSString * const simpleMappingCacheKey = @"VSequence.simpleMappingCacheKey";
    RKEntityMapping *mapping = [VObjectManager sharedManager].mappingCache[simpleMappingCacheKey];
    
    if ( mapping == nil )
    {
        mapping = [VSequence mappingBase];
        
        RKRelationshipMapping *previewImageAssetsMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"preview.assets"
                                                                                                       toKeyPath:VSelectorName(previewImageAssets)
                                                                                                     withMapping:[VImageAsset entityMapping]];
        
        [mapping addPropertyMapping:previewImageAssetsMapping];
        
        RKRelationshipMapping *previewTextPostMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"preview"
                                                                                                    toKeyPath:VSelectorName(previewTextPostAsset)
                                                                                                  withMapping:[VAsset textPostPreviewEntityMapping]];
        
        [mapping addPropertyMapping:previewTextPostMapping];
        
        RKRelationshipMapping *recentCommentsMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"recent_comments"
                                                                                                   toKeyPath:VSelectorName(recentComments)
                                                                                                 withMapping:[VComment inStreamEntityMapping]];
        
        [mapping addPropertyMapping:recentCommentsMapping];
        
        [mapping addRelationshipMappingWithSourceKeyPath:VSelectorName(nodes) mapping:[VNode entityMapping]];
        [mapping addRelationshipMappingWithSourceKeyPath:VSelectorName(comments) mapping:[VComment entityMapping]];
        [mapping addRelationshipMappingWithSourceKeyPath:VSelectorName(user) mapping:[VUser simpleMapping]];
        
        [VObjectManager sharedManager].mappingCache[simpleMappingCacheKey] = mapping;
    }
    return mapping;
}

+ (RKEntityMapping *)entityMapping
{
    static NSString * const entityMappingKey = @"VSequence.entityMappingKey";
    RKEntityMapping *mapping = [VObjectManager sharedManager].mappingCache[entityMappingKey];
    
    if ( mapping == nil )
    {
        mapping = [VSequence mappingBase];
        
        RKRelationshipMapping *previewImageAssetsMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"preview.assets"
                                                                                                       toKeyPath:VSelectorName(previewImageAssets)
                                                                                                     withMapping:[VImageAsset entityMapping]];
        
        [mapping addPropertyMapping:previewImageAssetsMapping];
        
        RKRelationshipMapping *previewTextPostMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"preview"
                                                                                                    toKeyPath:VSelectorName(previewTextPostAsset)
                                                                                                  withMapping:[VAsset textPostPreviewEntityMapping]];
        
        [mapping addPropertyMapping:previewTextPostMapping];
        
        RKRelationshipMapping *recentCommentsMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"recent_comments"
                                                                                                   toKeyPath:VSelectorName(recentComments)
                                                                                                 withMapping:[VComment inStreamEntityMapping]];
        
        [mapping addPropertyMapping:recentCommentsMapping];
        
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
        RKRelationshipMapping *trackingMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"tracking"
                                                                                             toKeyPath:VSelectorName(tracking)
                                                                                           withMapping:[VTracking entityMapping]];
        [mapping addPropertyMapping:adBreaksMapping];
        [mapping addPropertyMapping:trackingMapping];
        
        [VObjectManager sharedManager].mappingCache[entityMappingKey] = mapping;
    }
    return mapping;
}

+ (NSArray *)descriptors
{
    return @[
              [RKResponseDescriptor responseDescriptorWithMapping:[VSequence entityMapping]
                                                           method:RKRequestMethodGET
                                                      pathPattern:@"/api/sequence/fetch/:sequence_id"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              [RKResponseDescriptor responseDescriptorWithMapping:[VSequence entityMapping]
                                                           method:RKRequestMethodGET
                                                      pathPattern:@"/api/sequence/fetch/:sequence_id/:stream_id"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]
              ];
}

@end
