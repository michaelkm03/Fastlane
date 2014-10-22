//
//  VAdBreak.h
//  victorious
//
//  Created by Lawrence Leach on 10/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VSequence;

@interface VAdBreak : NSManagedObject

@property (nonatomic, retain) NSNumber * startPosition;
@property (nonatomic, retain) NSNumber * adSystem;
@property (nonatomic, retain) NSString * adTag;
@property (nonatomic, retain) NSNumber * timeout;
@property (nonatomic, retain) VSequence *sequence;

@end
