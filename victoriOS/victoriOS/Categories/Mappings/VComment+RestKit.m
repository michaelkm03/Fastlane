//
//  Comment+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VComment+RestKit.h"

@implementation VComment (RestKit)

+ (NSString *)entityName
{
    return @"Comment";
}

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"dislikes" : @"dislikes",
                                  @"display_order" : @"display_order",
                                  @"flags" : @"flags",
                                  @"id" : @"id",
                                  @"likes" : @"likes",
                                  @"media_type" : @"media_type",
                                  @"media_url" : @"media_url",
                                  @"parent_id" : @"parent_id",
                                  @"posted_at" : @"posted_at",
                                  @"sequence_id" : @"sequence_id",
                                  @"shares" : @"shares",
                                  @"text" : @"text"
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ @"id" ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

+ (RKResponseDescriptor*)descriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                        method:RKRequestMethodPOST | RKRequestMethodGET
                                                   pathPattern:@"/api/comment/:apicall"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}


+ (RKResponseDescriptor*)getAllDescriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                        method:RKRequestMethodPOST | RKRequestMethodGET
                                                   pathPattern:@"/api/comment/all/:sequenceid"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}
@end
