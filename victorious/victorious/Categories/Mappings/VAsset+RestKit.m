//
//  Asset+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VAsset+RestKit.h"

@implementation VAsset (RestKit)

+ (NSString *)entityName
{
    return @"Asset";
}

+ (RKDynamicMapping *)textPostPreviewEntityMapping
{
    RKDynamicMapping *dynamicMapping = [RKDynamicMapping new];
    [dynamicMapping setObjectMappingForRepresentationBlock:^RKObjectMapping *(id representation)
     {
         NSString *type = [representation valueForKey:@"type"];
         if ( [type isKindOfClass:[NSString class]] && [type isEqualToString:@"text"] )
         {
             NSDictionary *propertyMap = @{
                                           @"type" : VSelectorName(type),
                                           @"data" : VSelectorName(data),
                                           @"background_color" : VSelectorName(backgroundColor),
                                           @"background_image" : VSelectorName(backgroundImageUrl)
                                           };
             
             RKEntityMapping *mapping = [RKEntityMapping
                                         mappingForEntityForName:[self entityName]
                                         inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
             
             [mapping addAttributeMappingsFromDictionary:propertyMap];
             
             return mapping;
         }
         return nil;
     }];
    
    return dynamicMapping;
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"node_id" : VSelectorName(nodeId),
                                  @"type" : VSelectorName(type),
                                  @"mime_type" : VSelectorName(mimeType),
                                  @"data" : VSelectorName(data),
                                  @"speed" : VSelectorName(speed),
                                  @"loop" : VSelectorName(loop),
                                  @"asset_id" : VSelectorName(remoteId),
                                  @"stream_autoplay" : VSelectorName(streamAutoplay),
                                  @"player_controls_disabled" : VSelectorName(playerControlsDisabled),
                                  @"audio_muted" : VSelectorName(audioMuted),
                                  @"background_color" : VSelectorName(backgroundColor),
                                  @"duration" : VSelectorName(duration),
                                  @"remote_playback": VSelectorName(remotePlayback),
                                  @"remote_source": VSelectorName(remoteSource),
                                  @"remote_content_id": VSelectorName(remoteContentId)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];

    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

+ (RKEntityMapping *)entityMappingForVVoteType
{

    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [mapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:VSelectorName(data)]];
    
    return mapping;
}

@end
