//
//  VHashtag.h
//  victorious
//
//  Created by Lawrence Leach on 12/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VUser;

@interface VHashtag : NSManagedObject

@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, assign) BOOL isFollowedByMainUser;

@end
