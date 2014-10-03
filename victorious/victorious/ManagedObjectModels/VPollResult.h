//
//  VPollResult.h
//  victorious
//
//  Created by Will Long on 9/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VSequence, VUser;

@interface VPollResult : NSManagedObject

@property (nonatomic, retain) NSNumber * answerId;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSString * sequenceId;
@property (nonatomic, retain) VSequence *sequence;
@property (nonatomic, retain) VUser *user;

@end
