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
                                  @"view-start"         :   VSelectorName(videoStart),
                                  @"view-25-complete"   :   VSelectorName(videoComplete25),
                                  @"view-50-complete"   :   VSelectorName(videoComplete50),
                                  @"view-75-complete"   :   VSelectorName(videoComplete75),
                                  @"view-100-complete"  :   VSelectorName(videoComplete100),
                                  @"view-error"         :   VSelectorName(videoError),
                                  @"view-stall"         :   VSelectorName(videoStall),
                                  @"view-skip"          :   VSelectorName(videoSkip),
                                  @"cell-view"          :   VSelectorName(cellView),
                                  @"cell-click"         :   VSelectorName(cellClick),
                                  @"init"               :   VSelectorName(launch),
                                  @"start"              :   VSelectorName(enterForeground),
                                  @"stop"               :   VSelectorName(enterBackground),
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

@end

