//
//  VCreatorInfoHelper.h
//  victorious
//
//  Created by Patrick Lynch on 3/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDependencyManager;

@interface VCreatorInfoHelper : NSObject

- (void)populateViewsWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
