//
//  VCreatorInfoHelper.h
//  victorious
//
//  Created by Patrick Lynch on 3/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

// Owner info
extern NSString * const VDependencyManagerOwnerProfileImageKey;
extern NSString * const VDependencyManagerOwnerNameKey;
extern NSString * const VDependencyManagerOwnerInfoKey;

@class VDependencyManager;

@interface VCreatorInfoHelper : NSObject

- (void)populateViewsWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
