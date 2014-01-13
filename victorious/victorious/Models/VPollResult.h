//
//  VPollResult.h
//  victorious
//
//  Created by Will Long on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VUser;

@interface VPollResult : NSManagedObject

@property (nonatomic, retain) NSNumber * sequenceId;
@property (nonatomic, retain) NSNumber * answerId;
@property (nonatomic, retain) VUser *user;

@end
