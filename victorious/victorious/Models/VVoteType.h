//
//  VVoteType.h
//  victorious
//
//  Created by Will Long on 3/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VAsset;

@interface VVoteType : NSManagedObject

@property (nonatomic, retain) NSNumber * display_order;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) VAsset *assets;

@end
