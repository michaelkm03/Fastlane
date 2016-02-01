//
//  VSequencePollResults.h
//  victorious
//
//  Created by Tian Lan on 2/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import <CoreData/CoreData.h>

@class VSequence, VPollResult;

NS_ASSUME_NONNULL_BEGIN

@interface VSequencePollResults : NSManagedObject

@property (nonatomic, strong) VSequence *sequence;
@property (nonatomic, strong) NSSet<VPollResult *> *pollResults;

@end

NS_ASSUME_NONNULL_END
