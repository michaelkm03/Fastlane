//
//  Answer+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VAnswer+RestKit.h"
#import "VAnswerAction+RestKit.h"

@implementation VAnswer (RestKit)

+ (NSString *)entityName
{
    return @"Answer";
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"label" : VSelectorName(label),
                                  @"answer_id" : VSelectorName(remoteId),
                                  @"is_correct" : VSelectorName(isCorrect),
                                  @"label_media_url" : VSelectorName(mediaUrl),
                                  @"points" : VSelectorName(points),
                                  @"currency" : VSelectorName(currency),
                                  @"label_thumbnail_url" :  VSelectorName(thumbnailUrl)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    mapping.identificationAttributes = @[ VSelectorName(remoteId) ];

    [mapping addAttributeMappingsFromDictionary:propertyMap];

    //Now add relationships
    [mapping addRelationshipMappingWithSourceKeyPath:VSelectorName(answerAction) mapping:[VAnswerAction entityMapping]];

    
    return mapping;
}

@end
