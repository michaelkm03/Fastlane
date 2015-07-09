//
//  VGIFSearchResult+RestKit.m
//  victorious
//
//  Created by Patrick Lynch on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VGIFSearchResult+RestKit.h"

@implementation VGIFSearchResult (RestKit)

+ (NSString *)entityName
{
    return @"GIFSearchResult";
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"gif_url"           : VSelectorName(gifUrl),
                                  @"gif_size"          : VSelectorName(gifSize),
                                  @"mp4_url"           : VSelectorName(mp4Url),
                                  @"mp4_size"          : VSelectorName(mp4Size),
                                  @"frames"            : VSelectorName(frames),
                                  @"width"             : VSelectorName(width),
                                  @"height"            : VSelectorName(height),
                                  @"thumbnail"         : VSelectorName(thumbnailUrl),
                                  @"thumbnail_still"   : VSelectorName(thumbnailStillUrl) };
    
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:[self entityName]
                                                   inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    mapping.identificationAttributes = @[ @"gifUrl", @"mp4Url" ];
    return mapping;
}

+ (NSArray *)descriptors
{
    return @[
             [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                          method:RKRequestMethodAny
                                                     pathPattern:@"/api/image/gif_search/:search_term/:page/:perpage"
                                                         keyPath:@"payload"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             ];
}

@end
