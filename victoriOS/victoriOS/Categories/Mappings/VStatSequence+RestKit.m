//
//  StatSequence+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
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
                                  @"completed_at" : VSelectorName(completedAt),
                                  @"correct_answers" : VSelectorName(correctAnswers),
                                  @"id" : VSelectorName(statSequenceId),
                                  @"name" : VSelectorName(name),
                                  @"num_questions_answered" : VSelectorName(questionsAnswered),
                                  @"outcome" : VSelectorName(outcome),
                                  @"possible_points" : VSelectorName(possiblePoints),
                                  @"total_points" : VSelectorName(totalPoints),
                                  @"total_questions" : VSelectorName(totalQuestions)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(statSequenceId) ];
    
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
                                                   pathPattern:@"api/game/create"
                                                       keyPath:@"payload"
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}
@end
