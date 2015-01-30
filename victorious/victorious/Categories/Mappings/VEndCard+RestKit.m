//
//  VEndCard+RestKit.m
//  victorious
//
//  Created by Patrick Lynch on 1/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEndCard+RestKit.h"
#import "VSequence+RestKit.h"

@implementation VEndCard (RestKit)

+ (NSString *)entityName
{
    return @"EndCard";
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{ @"remix"     : VSelectorName(canRemix),
                                   @"repost"    : VSelectorName(canRepost),
                                   @"share"     : VSelectorName(canShare),
                                   @"timer_ms"  : VSelectorName(countDownDuration) };
    
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:[self entityName]
                                                   inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    return mapping;
}

@end
