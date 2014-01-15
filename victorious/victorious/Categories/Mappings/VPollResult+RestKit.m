//
//  VPollResult+RestKit.m
//  victorious
//
//  Created by Will Long on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPollResult+RestKit.h"

@implementation VPollResult (RestKit)

+ (NSString *)entityName
{
    return @"PollResult";
}

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"sequence_id" : VSelectorName(sequenceId),
                                  @"answer_id" : VSelectorName(answerId),
                                  @"total_count" : VSelectorName(count)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    [mapping addConnectionForRelationship:@"sequence" connectedBy:@{@"sequenceId" : @"remoteId"}];

    return mapping;
}

+ (RKResponseDescriptor*)descriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/pollresult/summary_by_sequence/:sequenceid"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}


+ (RKResponseDescriptor*)byUserDescriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/pollresult/summary_by_user/:userid"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+ (RKResponseDescriptor*)createPollResultDescriptor
{
    
    return [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                        method:RKRequestMethodPOST
                                                   pathPattern:@"/api/pollresult/create"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

@end
