//
//  VMedia+RestKit.m
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMedia+RestKit.h"

@implementation VMedia (RestKit)

+ (NSString *)entityName
{
    return @"Media";
}

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"media_url" : VSelectorName(mediaUrl),
                                  @"media_type" : VSelectorName(mediaType),
                                  @"preview_image" : VSelectorName(previewImage)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

@end