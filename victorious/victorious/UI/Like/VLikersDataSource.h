//
//  VLikersDataSource.h
//  victorious
//
//  Created by Patrick Lynch on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

#import "VUsersDataSource.h"

@class VSequence;

@interface VLikersDataSource : NSObject <VUsersDataSource>

- (instancetype)initWithUser:(VSequence *)sequence NS_DESIGNATED_INITIALIZER;

@end
