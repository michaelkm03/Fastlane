//
//  StatSequence+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "StatSequence+RestKit.h"

@implementation StatSequence (RestKit)

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"completed_at" : @"completed_at",
                                  @"correct_answers" : @"correct_answers",
                                  @"id" : @"id",
                                  @"name" : @"name",
                                  @"num_questions_answered" : @"num_questions_answered",
                                  @"outcome" : @"outcome",
                                  @"possible_points" : @"possible_points",
                                  @"total_points" : @"total_points",
                                  @"total_questions" : @"total_questions"
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:NSStringFromClass([StatSequence class])
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ @"id" ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

+ (RKResponseDescriptor*)gamesPlayedDescriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[StatSequence entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/userinfo/games_played/:id"
                                                       keyPath:@"payload"                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+ (RKResponseDescriptor*)gameStatsDescriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[StatSequence entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/userinfo/game_stats/:id"
                                                       keyPath:@"payload"                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+ (RKResponseDescriptor*)createGameDescriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[StatSequence entityMapping]
                                                        method:RKRequestMethodPOST
                                                   pathPattern:@"api/game/create"
                                                       keyPath:@"payload"                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}
@end
