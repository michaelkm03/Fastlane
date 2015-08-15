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
#import "victorious-Swift.h"

@implementation VShelf (RestKit)

+ (NSDictionary *)propertyMap
{
    return @{
             @"id"      :   VSelectorName(remoteId),
             @"type"    :   VSelectorName(itemType),
             @"subtype" :   VSelectorName(itemSubType),
             };
}

+ (RKEntityMapping *)mappingBaseForEntityWithName:(NSString *)entityName
{
    NSDictionary *propertyMap = [VShelf propertyMap];
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:entityName
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    RKRelationshipMapping *contentMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:nil
                                                                                        toKeyPath:VSelectorName(stream)
                                                                                      withMapping:[VStream feedPayloadMapping]];
    [mapping addPropertyMapping:contentMapping];
    
    return mapping;
}

+ (RKObjectMapping *)mappingForItemType:(NSString *)type
{
    RKObjectMapping *mapping = [self mappingBaseForEntityWithName:@"Shelf"];
    if ( [type isEqualToString:VStreamItemTypeUser] )
    {
        mapping = [UserShelf entityMapping];
    }
    else if ( [type isEqualToString:VStreamItemTypeHashtag] )
    {
        mapping = [HashtagShelf entityMapping];
    }
    return mapping;
}

@end
