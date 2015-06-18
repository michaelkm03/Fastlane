//
//  VEndCardModelBuilder.h
//  victorious
//
//  Created by Patrick Lynch on 4/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VHasManagedDependencies.h"

@class VSequence, VEndCardModel;

@interface VEndCardModelBuilder : NSObject <VHasManagedDependencies>

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager NS_DESIGNATED_INITIALIZER;

/**
 Creates a VEndCardModel object based on the provided sequence.
 Returns nil if there is no endcard with a valid "next sequence" with which
 to populate the end card UI.
 */
- (VEndCardModel *)createWithSequence:(VSequence *)sequence;

@end
