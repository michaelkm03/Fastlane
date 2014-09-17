//
//  VAnswer.h
//  victorious
//
//  Created by Will Long on 9/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VAnswerAction, VInteraction;

@interface VAnswer : NSManagedObject

@property (nonatomic, retain) NSNumber * currency;
@property (nonatomic, retain) NSNumber * isCorrect;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSString * mediaUrl;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSString * thumbnailUrl;
@property (nonatomic, retain) VAnswerAction *answerAction;
@property (nonatomic, retain) VInteraction *interaction;

@end
