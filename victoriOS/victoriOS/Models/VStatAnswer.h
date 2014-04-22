//
//  VStatAnswer.h
//  victoriOS
//
//  Created by David Keegan on 12/13/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VStatInteraction;

@interface VStatAnswer : NSManagedObject

@property (nonatomic, retain) NSNumber * answeredAt;
@property (nonatomic, retain) NSNumber * answerId;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * currency;
@property (nonatomic, retain) NSNumber * isCorrect;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) VStatInteraction *interaction;

@end
