//
//  VVoteType.h
//  victorious
//
//  Created by Will Long on 3/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VTracking;

@interface VVoteType : NSManagedObject

@property (nonatomic, retain) NSNumber *displayOrder;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *remoteId;
@property (nonatomic, retain) NSString *iconImage;
@property (nonatomic, retain) NSString *iconImageLarge;
@property (nonatomic, retain) NSString *imageFormat;
@property (nonatomic, retain) NSNumber *imageCount;
@property (nonatomic, retain) NSNumber *flightDuration;
@property (nonatomic, retain) NSNumber *animationDuration;
@property (nonatomic, retain) NSNumber *settingsIndex;
@property (nonatomic, retain) NSNumber *isPaid;
@property (nonatomic, retain) NSString *imageContentMode;
@property (nonatomic, retain) NSString *productIdentifier;
@property (nonatomic, retain) VTracking *tracking;

@end
