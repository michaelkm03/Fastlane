//
//  VAdBreakFallback+RestKit.m
//  victorious
//
//  Created by Lawrence Leach on 10/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAdBreakFallback+RestKit.h"
#import "VSequence+RestKit.h"

@implementation VAdBreakFallback (RestKit)

+ (NSString *)entityName
{
    return @"AdBreakFallback";
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"ad_system" : VSelectorName(adSystem),
                                  @"ad_tag" : VSelectorName(adTag),
                                  @"timeout" : VSelectorName(timeout),
                                  @"publisher_id": VSelectorName(publisherId),
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    
    return mapping;
}

@end
