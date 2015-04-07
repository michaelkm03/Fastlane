//
//  VEndCardModelFactory.h
//  victorious
//
//  Created by Patrick Lynch on 4/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VHasManagedDependencies.h"

@class VSequence, VEndCardModel;

@interface VEndCardModelFactory : NSObject <VHasManagedDependencies>

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager NS_DESIGNATED_INITIALIZER;

- (VEndCardModel *)createWithSequence:(VSequence *)sequence;

@end
