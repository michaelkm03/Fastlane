//
//  VShelf+RestKit.m
//  victorious
//
//  Created by Sharif Ahmed on 8/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VShelf+RestKit.h"
#import "VStream+RestKit.h"
#import "VSequence+RestKit.h"

@implementation VShelf (RestKit)

+ (NSString *)entityName
{
    return @"Shelf";
}

+ (NSDictionary *)propertyMap
{
    return @{
             @"id"      :   VSelectorName(remoteId),
             @"type"    :   VSelectorName(streamType),
             @"subtype" :   VSelectorName(subType),
             };
}

+ (RKEntityMapping *)mappingBase
{
    NSDictionary *propertyMap = [VShelf propertyMap];
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[VShelf entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    RKRelationshipMapping *contentMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:nil
                                                                                        toKeyPath:VSelectorName(stream)
                                                                                      withMapping:[VStream feedPayloadMapping]];
    [mapping addPropertyMapping:contentMapping];
    
    return mapping;
}

+ (RKEntityMapping *)entityMapping
{
    return [self mappingBase];
}

+ (RKObjectMapping *)mappingForStreamSubType:(NSString *)subType
{
    RKObjectMapping *mapping = nil;
    if ( [subType isEqualToString:@"marquee"] )
    {
        mapping = [self marqueeShelfMapping];
    }
    return mapping;
}

#pragma mark - subtype mappings

+ (RKEntityMapping *)marqueeShelfMapping
{
    return [self mappingBase];
}

@end
