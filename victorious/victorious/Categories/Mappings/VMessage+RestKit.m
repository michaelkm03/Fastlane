//
//  VMessage+RestKit.m
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMessage+RestKit.h"

#import "VMedia+RestKit.h"

@implementation VMessage (RestKit)

+ (NSString *)entityName
{
    return @"Message";
}

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"is_read" : VSelectorName(isRead),
                                  @"text" : VSelectorName(text),
                                  @"remote_id" : VSelectorName(remoteId),
                                  @"posted_at" : VSelectorName(postedAt)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    [mapping addRelationshipMappingWithSourceKeyPath:@"" mapping:[VMedia entityMapping]];
    
    return mapping;
}

@end
