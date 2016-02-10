//
//  VTracking.h
//  victorious
//
//  Created by Patrick Lynch on 10/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VStreamItemPointer;

NS_ASSUME_NONNULL_BEGIN

@interface VTracking : NSManagedObject

@property (nonatomic, retain, nullable) id cellClick;
@property (nonatomic, retain, nullable) id cellView;
@property (nonatomic, retain, nullable) id videoComplete25;
@property (nonatomic, retain, nullable) id videoComplete50;
@property (nonatomic, retain, nullable) id videoComplete75;
@property (nonatomic, retain, nullable) id videoComplete100;
@property (nonatomic, retain, nullable) id viewStop;
@property (nonatomic, retain, nullable) id videoError;
@property (nonatomic, retain, nullable) id videoSkip;
@property (nonatomic, retain, nullable) id videoStall;
@property (nonatomic, retain, nullable) id viewStart;
@property (nonatomic, retain, nullable) id share;

@end

NS_ASSUME_NONNULL_END
