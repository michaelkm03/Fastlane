//
//  VVoteType.h
//  victorious
//
//  Created by Will Long on 3/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 A configuration setting received from the server indicating which
 vote actions (VVoteAction) can be made while viewing a sequence.
 */
@interface VVoteType : NSManagedObject

@property (nonatomic, retain) NSNumber *displayOrder;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *remoteId;
@property (nonatomic, retain) NSString *iconImage;
@property (nonatomic, retain) NSString *imageFormat;
@property (nonatomic, retain) NSNumber *imageCount;
@property (nonatomic, retain) NSNumber *flightDuration;
@property (nonatomic, retain) NSNumber *animationDuration;

@end
