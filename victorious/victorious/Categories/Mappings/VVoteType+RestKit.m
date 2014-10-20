//
//  VVoteType+RestKit.m
//  victorious
//
//  Created by Will Long on 3/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVoteType+RestKit.h"

#import "VAsset+RestKit.h"

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
                                  @"images"             : VSelectorName(images),
                                  @"frames"             : VSelectorName(imageCount),
                                  @"image"              : VSelectorName(imageFormat),
                                  @"icon_image"         : VSelectorName(iconImage),
                                  @"animation_duration" : VSelectorName(animationDuration),
                                  @"flight_duration"    : VSelectorName(flightDuration)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
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
