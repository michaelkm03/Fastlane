//
//  VVoteType+RestKit.m
//  victorious
//
//  Created by Will Long on 3/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVoteType+RestKit.h"
#import "VAsset+RestKit.h"
#import "VTracking+RestKit.h"

@implementation VVoteType (RestKit)

+ (NSString *)entityName
{
    return @"VoteType";
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"display_order"      : VSelectorName(displayOrder),
                                  @"name"               : VSelectorName(name),
                                  @"id"                 : VSelectorName(remoteId),
                                  @"frames"             : VSelectorName(imageCount),
                                  @"image_macro"        : VSelectorName(imageFormat),
                                  @"icon"               : VSelectorName(iconImage),
                                  @"animation_duration" : VSelectorName(animationDuration),
                                  @"flight_duration"    : VSelectorName(flightDuration),
                                  @"view_content_mode"  : VSelectorName(imageContentMode),
                                  @"is_paid"            : VSelectorName(isPaid),
                                  @"apple_product_id"   : VSelectorName(productIdentifier)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    RKRelationshipMapping *trackingMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"tracking"
                                                                                          toKeyPath:VSelectorName(tracking)
                                                                                        withMapping:[VTracking entityMapping]];
    [mapping addPropertyMapping:trackingMapping];
    
    return mapping;
}

+ (RKResponseDescriptor *)descriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/init"
                                                       keyPath:@"payload.votetypes"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

@end
