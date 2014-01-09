//
//  StatSequence+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VStatSequence+RestKit.h"

@implementation VStatSequence (RestKit)

+ (NSString *)entityName
{
    return @"StatSequence";
}

+ (RKEntityMapping*)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"possible_points" : VSelectorName(possiblePoints),
                                  @"total_questions" : VSelectorName(totalQuestions),
                                  @"total_points" : VSelectorName(totalPoints),
                                  @"num_questions_answered_correctly" : VSelectorName(questionsAnsweredCorrectly),
                                  @"num_questions_answered" : VSelectorName(questionsAnswered),
                                  @"name" : VSelectorName(name),
                                  @"outcome" : VSelectorName(outcome),
                                  @"completed_at" : VSelectorName(completedAt),
                                  @"id" : VSelectorName(remoteId),
                                  @"user_id" : VSelectorName(userId)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

+ (RKResponseDescriptor*)gamesPlayedDescriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[VStatSequence entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/userinfo/games_played/:id"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+ (RKResponseDescriptor*)gameStatsDescriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[VStatSequence entityMapping]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/userinfo/game_stats/:id"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+ (RKResponseDescriptor*)createGameDescriptor
{
    return [RKResponseDescriptor responseDescriptorWithMapping:[VStatSequence entityMapping]
                                                        method:RKRequestMethodPOST
                                                   pathPattern:@"/api/game/create"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}
@end
