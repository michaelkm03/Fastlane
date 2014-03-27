//
//  VObjectManager.h
//  victorious
//
//  Created by Will Long on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "RKObjectManager.h"

@class VUser;

/*! Block that executes when the request succeeds.*/
typedef void (^VSuccessBlock) (NSOperation*, id, NSArray*);
/*! Block that executes when the request fails.*/
typedef void (^VFailBlock) (NSOperation*, NSError*);

@interface VObjectManager : RKObjectManager

@property (nonatomic, strong) VUser*  mainUser;

+ (void)setupObjectManager;

@end
