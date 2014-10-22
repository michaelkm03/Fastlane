//
//  VVoteAction.h
//  victorious
//
//  Created by Patrick Lynch on 10/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "VSequence.h"

/**
 A representation of a user's vote on a sequence used for sending to the server.
 */
@interface VVoteAction : NSManagedObject

@property (nonatomic, retain) VSequence *sequence;
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, retain) NSDate *date;

@end
