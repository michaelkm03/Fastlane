//
//  VCommentMedia+RestKit.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCommentMedia+RestKit.h"

@implementation VMediaAttachment (RestKit)

+ (NSString *)entityName
{
    return @"MediaAttachment";
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"data" : VSelectorName(mediaURL),
                                  @"mime_type" : VSelectorName(mimeType)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(mediaURL) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

@end
