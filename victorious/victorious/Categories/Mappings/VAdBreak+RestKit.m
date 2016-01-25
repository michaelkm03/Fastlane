//
//  VAdBreak+RestKit.m
//  victorious
//
//  Created by Lawrence Leach on 10/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAdBreak+RestKit.h"
#import "VSequence+RestKit.h"

@implementation VAdBreak (RestKit)

+ (NSString *)entityName
{
    return @"AdBreak";
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"start_pos" : VSelectorName(startPosition),
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];

    return mapping;
}

@end
