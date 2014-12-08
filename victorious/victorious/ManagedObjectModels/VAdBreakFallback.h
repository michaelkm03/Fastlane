//
//  VAdBreakFallback.h
//  victorious
//
//  Created by Lawrence Leach on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VAdBreak;

@interface VAdBreakFallback : NSManagedObject

@property (nonatomic, retain) NSNumber * adSystem;
@property (nonatomic, retain) NSString * adTag;
@property (nonatomic, retain) NSString * publisherId;
@property (nonatomic, retain) NSNumber * timeout;
@property (nonatomic, retain) NSString * tremorAppId;
@property (nonatomic, retain) VAdBreak *adbreak;

@end
