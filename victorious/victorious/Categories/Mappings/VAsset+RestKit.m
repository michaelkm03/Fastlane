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
                                  @"audio_muted" : VSelectorName(audioMuted)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    // TODO: uncomment this after back-end fixes their shit or figure out another way to identify duplicate assets
//    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];

    [mapping addConnectionForRelationship:@"comments" connectedBy:@{@"remoteId" : @"assetId"}];
    
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
