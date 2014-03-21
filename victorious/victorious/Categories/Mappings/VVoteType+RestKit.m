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

//@property (nonatomic, retain) NSNumber * display_order;
//@property (nonatomic, retain) NSString * name;
//@property (nonatomic, retain) NSNumber * remoteId;
//@property (nonatomic, retain) VAsset *assets;

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"display_order"  : VSelectorName(display_order),
                                  @"name"           : VSelectorName(name),
                                  @"remote_id"      : VSelectorName(remoteId)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];

    [mapping addRelationshipMappingWithSourceKeyPath:VSelectorName(assets) mapping:[VAsset entityMappingForVVoteType]];

    return mapping;
}

+ (RKResponseDescriptor*)descriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/init"
                                                       keyPath:@"payload.votetypes"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

@end
