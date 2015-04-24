//
//  VHermesStreamCellFactory.h
//  victorious
//
//  Created by Michael Sena on 4/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VStreamCellFactory.h"
#import "VHasManagedDependencies.h"

@interface VHermesStreamCellFactory : NSObject <VHasManagedDependencies, VStreamCellFactory>

/**
 Initializes the stream cell factory with an instance of VDependencyManager
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager NS_DESIGNATED_INITIALIZER;

@end
