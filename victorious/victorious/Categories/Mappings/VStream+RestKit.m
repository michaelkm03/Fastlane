//
//  VStream+RestKit.m
//  victorious
//
//  Created by Will Long on 9/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStream+RestKit.h"

#import "VSequence+RestKit.h"

@implementation VStream (RestKit)

+ (NSString *)entityName
{
    return @"VStream";
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"id"             :   VSelectorName(remoteId),
                                  @"stream_content_type"     :   VSelectorName(streamContentType),
                                  @"name"           :   VSelectorName(name),
                                  @"preview_images"  :   VSelectorName(previewImagesObject),
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
        
    RKDynamicMapping *contentMapping = [RKDynamicMapping new];
    RKObjectMapping *sequenceMapping = [VSequence entityMapping];
    
    [contentMapping addMatcher:[RKObjectMappingMatcher matcherWithKeyPath:@"stream_content_type"
                                                     expectedValue:@"stream"
                                                     objectMapping:mapping]];
    
    [contentMapping addMatcher:[RKObjectMappingMatcher matcherWithKeyPath:@"stream_content_type"
                                                     expectedValue:@"sequence"
                                                     objectMapping:sequenceMapping]];
    
    RKRelationshipMapping *contentRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"content"
                                                                                           toKeyPath:VSelectorName(streamItems)
                                                                                         withMapping:contentMapping];
    [mapping addPropertyMapping:contentRelationshipMapping];
    
    return mapping;
}

+ (NSArray *)descriptors
{
    return @[ [RKResponseDescriptor responseDescriptorWithMapping:[VStream entityMapping]
                                                           method:RKRequestMethodGET
                                                      pathPattern:@"/api/sequence/detail_list_by_stream/:streamId/:page/:perpage"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
              ];
}

@end
/*
{
error: 0,
message: "",
api_version: "2",
host: "Matthews-MacBook-Pro.local",
app_id: 1,
user_id: null,
page_number: 1,
total_pages: 1,
payload: {
content: [
    {
        id: 1,
    name: "stream1",
    preview_images: [
                     "http://www.getvictorious.com/1.png",
                     "http://www.getvictorious.com/2.png",
                     "http://www.getvictorious.com/3.png"
                     ],
    stream_content_type: "stream"
    },
    {
        id: 2,
    name: "stream2",
    preview_images: [
                     "http://www.getvictorious.com/4.png",
                     "http://www.getvictorious.com/5.png",
                     "http://www.getvictorious.com/6.png"
                     ],
    stream_content_type: "stream"
    },
    {
        id: 3,
    name: "stream3",
    preview_images: [
                     "http://www.getvictorious.com/7.png",
                     "http://www.getvictorious.com/8.png",
                     "http://www.getvictorious.com/9.png"
                     ],
    stream_content_type: "stream"
    }
          ],
    id: 0,
preview_images: [
                 "http://www.getvictorious.com/1.png",
                 "http://www.getvictorious.com/2.png",
                 "http://www.getvictorious.com/3.png"
                 ],
stream_content_type: "stream"
}
}*/