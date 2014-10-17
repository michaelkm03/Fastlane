//
//  VAnalytics.h
//  victorious
//
//  Created by Patrick Lynch on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VSequence;

@interface VAnalytics : NSManagedObject

@property (nonatomic, retain) id cellView;
@property (nonatomic, retain) id cellClick;
@property (nonatomic, retain) id videoStart;
@property (nonatomic, retain) id videoError;
@property (nonatomic, retain) id videoStall;
@property (nonatomic, retain) id videoSkip;
@property (nonatomic, retain) id videoComplete25;
@property (nonatomic, retain) id videoComplete50;
@property (nonatomic, retain) id videoComplete75;
@property (nonatomic, retain) id videoComplete100;
@property (nonatomic, retain) VSequence *parentEntity;

@end
