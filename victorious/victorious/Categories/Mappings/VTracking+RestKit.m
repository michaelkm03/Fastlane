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
                                  @"view-start"             :   VSelectorName(viewStart),
                                  @"view-stop"              :   VSelectorName(viewStop),
                                  @"view-25-complete"       :   VSelectorName(videoComplete25),
                                  @"view-50-complete"       :   VSelectorName(videoComplete50),
                                  @"view-75-complete"       :   VSelectorName(videoComplete75),
                                  @"view-100-complete"      :   VSelectorName(videoComplete100),
                                  @"view-error"             :   VSelectorName(videoError),
                                  @"view-stall"             :   VSelectorName(videoStall),
                                  @"view-skip"              :   VSelectorName(videoSkip),
                                  @"cell-view"              :   VSelectorName(cellView),
                                  @"cell-click"             :   VSelectorName(cellClick),
                                  @"share"                  :   VSelectorName(share),
                                  @"autoplay-view"          :   VSelectorName(autoplayView),
                                  @"autoplay-click"         :   VSelectorName(autoplayClick),
                                  @"autoplay-view-25"       :   VSelectorName(autoplayComplete25),
                                  @"autoplay-view-50"       :   VSelectorName(autoplayComplete50),
                                  @"autoplay-view-75"       :   VSelectorName(autoplayComplete75),
                                  @"autoplay-view-100"      :   VSelectorName(autoplayComplete100),
                                  @"autoplay-view-stall"    :   VSelectorName(autoplayViewStall)};
    
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

