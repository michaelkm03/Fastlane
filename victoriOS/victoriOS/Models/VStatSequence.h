//
//  VStatSequence.h
//  victoriOS
//
//  Created by David Keegan on 12/13/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VStatInteraction, VUser;

@interface VStatSequence : NSManagedObject

@property (nonatomic, retain) NSDate * completedAt;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * outcome;
@property (nonatomic, retain) NSNumber * possiblePoints;
@property (nonatomic, retain) NSNumber * questionsAnswered;
@property (nonatomic, retain) NSNumber * questionsAnsweredCorrectly;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSNumber * totalPoints;
@property (nonatomic, retain) NSNumber * totalQuestions;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSSet *interactionDetails;
@property (nonatomic, retain) VUser *user;
@end

@interface VStatSequence (CoreDataGeneratedAccessors)

- (void)addInteractionDetailsObject:(VStatInteraction *)value;
- (void)removeInteractionDetailsObject:(VStatInteraction *)value;
- (void)addInteractionDetails:(NSSet *)values;
- (void)removeInteractionDetails:(NSSet *)values;

@end
