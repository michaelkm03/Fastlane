//
//  OXMStopWatch.h
//  AdLike
//
//  Created by Jon Flanders on 6/30/14.
//  Copyright (c) 2014 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OXMStopWatch : NSObject
@property (nonatomic,strong)NSDate* startDate;
@property (nonatomic,strong)NSDate* endDate;
@property (nonatomic,strong)NSMutableArray* events;
@property (nonatomic,assign)BOOL debugOutput;
@property (nonatomic,readonly) NSString* stopWatchName;
-(instancetype)initWithName:(NSString*)stopWatchName;
-(void)start;
-(void)stop;
-(NSTimeInterval)ellapsedTime;
-(void)event:(NSString*)eventName;
@end
