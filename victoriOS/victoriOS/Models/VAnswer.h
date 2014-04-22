//
//  VAnswer.h
//  victoriOS
//
//  Created by David Keegan on 12/13/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VAnswerAction, VInteraction;

@interface VAnswer : NSManagedObject

@property (nonatomic, retain) NSNumber * currency;
@property (nonatomic, retain) NSNumber * display_order;
@property (nonatomic, retain) NSNumber * isCorrect;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) VAnswerAction *answerAction;
@property (nonatomic, retain) VInteraction *interaction;

@end
