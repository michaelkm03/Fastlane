//
//  VEndCard.h
//  victorious
//
//  Created by Patrick Lynch on 1/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VSequence;

@interface VEndCard : NSManagedObject

@property (nonatomic, retain) NSNumber *canRemix;
@property (nonatomic, retain) NSNumber *canRepost;
@property (nonatomic, retain) NSNumber *canShare;
@property (nonatomic, retain) NSNumber *countdownDuration;
@property (nonatomic, retain) VSequence *parentSequence;
@property (nonatomic, retain) VSequence *nextSequence;

@end
