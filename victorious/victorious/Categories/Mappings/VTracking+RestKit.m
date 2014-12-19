//
//  VTracking+RestKit.m
//  victorious
//
//  Created by Patrick Lynch on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTracking+RestKit.h"
#import "VSequence+RestKit.h"

@implementation VTracking (RestKit)

+ (NSString *)entityName
{
    return @"Tracking";
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"view-start"         :   VSelectorName(viewStart),
                                  @"view-25-complete"   :   VSelectorName(videoComplete25),
                                  @"view-50-complete"   :   VSelectorName(videoComplete50),
                                  @"view-75-complete"   :   VSelectorName(videoComplete75),
                                  @"view-100-complete"  :   VSelectorName(videoComplete100),
                                  @"view-error"         :   VSelectorName(videoError),
                                  @"view-stall"         :   VSelectorName(videoStall),
                                  @"view-skip"          :   VSelectorName(videoSkip),
                                  @"cell-view"          :   VSelectorName(cellView),
                                  @"cell-click"         :   VSelectorName(cellClick),
                                  @"init"               :   VSelectorName(appLaunch),
                                  @"start"              :   VSelectorName(appEnterForeground),
                                  @"stop"               :   VSelectorName(appEnterBackground),
                                  @"ballistic_count"    :   VSelectorName(ballisticCount),
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

+ (RKResponseDescriptor *)descriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/init"
                                                       keyPath:@"payload.tracking"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+ (BOOL)urlsAreValid:(id)property
{
    if ( ![property isKindOfClass:[NSArray class]] )
    {
        return NO;
    }
    
    NSArray *urls = (NSArray *)property;
    if ( urls.count == 0 )
    {
        return NO;
    }
    
    __block BOOL containsValidUrls = YES;
    [urls enumerateObjectsUsingBlock:^(NSString *url, NSUInteger idx, BOOL *stop) {
        if ( url == nil || ![url isKindOfClass:[NSString class]] || url.length == 0 )
        {
            containsValidUrls = NO;
            *stop = YES;
        }
    }];
    
    return containsValidUrls;
}

@end

