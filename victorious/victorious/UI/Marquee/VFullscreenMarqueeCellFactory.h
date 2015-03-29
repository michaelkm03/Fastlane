//
//  VBaseMarqueeCellFactory.h
//  victorious
//
//  Created by Sharif Ahmed on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VMarqueeCellFactory.h"
#import "VFullscreenMarqueeControllerDelegate.h"

@class VDependencyManager;

@interface VFullscreenMarqueeCellFactory : NSObject <VMarqueeCellFactory>

/**
 Initializes the stream cell factory with an instance of VDependencyManager
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager NS_DESIGNATED_INITIALIZER;

@property (nonatomic, weak) id <VFullscreenMarqueeControllerDelegate> delegate;

@end
