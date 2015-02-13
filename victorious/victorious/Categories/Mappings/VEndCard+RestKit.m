//
//  VEndCard+RestKit.m
//  victorious
//
//  Created by Patrick Lynch on 1/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEndCard+RestKit.h"
#import "VSequence+RestKit.h"
#import "VUser+RestKit.h"

@implementation VEndCard (RestKit)

+ (NSString *)entityName
{
    return @"EndCard";
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{ @"remix"     : VSelectorName(canRemix),
                                   @"repost"    : VSelectorName(canRepost),
                                   @"share"     : VSelectorName(canShare),
                                   @"autoplay.timer_ms"  : VSelectorName(countdownDuration),
                                   @"autoplay.stream_name"  : VSelectorName(streamName) };

    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:[self entityName]
                                                   inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    RKRelationshipMapping *sequenceMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"autoplay.sequence"
                                                                                        toKeyPath:VSelectorName(nextSequence)
                                                                                       withMapping:[[self class] childSequenceEntityMapping]];
    [mapping addPropertyMapping:sequenceMapping];
    
    return mapping;
}

+ (RKEntityMapping *)childSequenceEntityMapping
{
    NSDictionary *propertyMap = @{
                                  @"id"             :   VSelectorName(remoteId),
                                  @"preview_image"  :   VSelectorName(previewImagesObject),
                                  @"description"    :   VSelectorName(sequenceDescription),
                                  @"category"       :   VSelectorName(category),
                                  @"status"         :   VSelectorName(status),
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:[VSequence entityName]
                                                   inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user"
                                                                            toKeyPath:@"user"
                                                                          withMapping:[VUser entityMapping]]];
    return mapping;
}

@end
