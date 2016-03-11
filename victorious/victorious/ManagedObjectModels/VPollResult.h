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

NS_ASSUME_NONNULL_BEGIN

@interface VPollResult : NSManagedObject

@property (nonatomic, retain, nullable) NSNumber * answerId;
@property (nonatomic, retain, nullable) NSNumber * count;
@property (nonatomic, retain, nullable) NSString * sequenceId;
@property (nonatomic, retain, nullable) VUser *user;
@property (nonatomic, retain) NSNumber * displayOrder;

@end

NS_ASSUME_NONNULL_END
