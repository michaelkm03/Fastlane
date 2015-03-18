//
//  VSleekStreamCellFactory.h
//  victorious
//
//  Created by Sharif Ahmed on 3/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"
#import "VStreamCellFactory.h"

#import <Foundation/Foundation.h>

@interface VSleekStreamCellFactory : NSObject <VHasManagedDependancies, VStreamCellFactory>

/**
 Initializes the stream cell factory with an instance of VDependencyManager
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager NS_DESIGNATED_INITIALIZER;

@end
