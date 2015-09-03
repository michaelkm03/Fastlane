//
//  Comment+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VComment+RestKit.h"
#import "VCommentMedia+RestKit.h"
#import "VUser+RestKit.h"

@implementation VComment (RestKit)

+ (NSString *)entityName
{
    return @"Comment";
}

+ (RKEntityMapping *)baseMapping
{
    NSDictionary *propertyMap = @{
                                  @"id" : VSelectorName(remoteId),
                                  @"sequence_id" : VSelectorName(sequenceId),
                                  @"parent_id" : VSelectorName(parentId),
                                  @"user_id" : VSelectorName(userId),
                                  @"text" : VSelectorName(text),
                                  @"media_type" : VSelectorName(mediaType),
                                  @"media_url" : VSelectorName(mediaUrl),
                                  @"likes" : VSelectorName(likes),
                                  @"dislikes" : VSelectorName(dislikes),
                                  @"flags" : VSelectorName(flags),
                                  @"posted_at" : VSelectorName(postedAt),
                                  @"thumbnail_url" : VSelectorName(thumbnailUrl),
                                  @"realtime" : VSelectorName(realtime),
                                  @"media_width" : VSelectorName(mediaWidth),
                                  @"media_height" : VSelectorName(mediaHeight),
                                  @"should_autoplay" : VSelectorName(shouldAutoplay)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    [mapping addRelationshipMappingWithSourceKeyPath:VSelectorName(user) mapping:[VUser simpleMapping]];
    
    // Comment media
    RKRelationshipMapping *commentMediaMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"media"
                                                                                             toKeyPath:VSelectorName(commentMedia)
                                                                                           withMapping:[VMediaAttachment entityMapping]];
    
    [mapping addPropertyMapping:commentMediaMapping];
    
    return mapping;
}

+ (RKEntityMapping *)inStreamEntityMapping
{
    RKEntityMapping *mapping = [self baseMapping];

    [mapping addConnectionForRelationship:@"inStreamSequence" connectedBy:@{@"sequenceId" : @"remoteId"}];
    
    return mapping;
}

+ (RKEntityMapping *)entityMapping
{
    RKEntityMapping *mapping = [self baseMapping];
    
    [mapping addConnectionForRelationship:@"sequence" connectedBy:@{@"sequenceId" : @"remoteId"}];

    return mapping;
}

+ (NSArray *)descriptors
{
    return @[ [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                        method:RKRequestMethodPOST | RKRequestMethodGET
                                                   pathPattern:@"/api/comment/:apicall"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
               
               [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                            method:RKRequestMethodGET
                                                       pathPattern:@"/api/comment/fetch/:commentid"
                                                           keyPath:@"payload"
                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                           method:RKRequestMethodPOST | RKRequestMethodGET
                                                      pathPattern:@"/api/comment/all/:sequenceid"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                           method:RKRequestMethodPOST | RKRequestMethodGET
                                                      pathPattern:@"/api/comment/all/:sequenceid/:page/:perpage"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                           method:RKRequestMethodPOST | RKRequestMethodGET
                                                      pathPattern:@"/api/comment/all_by_asset_filtered/:asset_id"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                           method:RKRequestMethodPOST | RKRequestMethodGET
                                                      pathPattern:@"/api/comment/all_by_asset/:asset_id"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                           method:RKRequestMethodPOST | RKRequestMethodGET
                                                      pathPattern:@"/api/comment/all_by_asset/:asset_id/:page/:perpage"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                           method:RKRequestMethodPOST | RKRequestMethodGET
                                                      pathPattern:@"/api/comment/add"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                           method:RKRequestMethodPOST | RKRequestMethodGET
                                                      pathPattern:@"/api/comment/edit"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                           method:RKRequestMethodPOST | RKRequestMethodGET
                                                      pathPattern:@"/api/comment/remove"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              
              [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                           method:RKRequestMethodPOST | RKRequestMethodGET
                                                      pathPattern:@"/api/comment/find/:sequenceid/:commentid/:perpage"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]
               ];
}

@end
