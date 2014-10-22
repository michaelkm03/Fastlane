//
//  VVoteResult.h
//  victorious
//
//  Created by Will Long on 4/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 A representation of vote statics for a sequence used to show
 vote activity for a sequence when viewing it.
 */
@class VSequence;

@interface VVoteResult : NSManagedObject

@property (nonatomic, retain) NSNumber *count;
@property (nonatomic, retain) NSNumber *remoteId;
@property (nonatomic, retain) VSequence *sequence;

@end
