//
//  VTextToolController.h
//  victorious
//
//  Created by Patrick Lynch on 3/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VToolController.h"
#import "VTextListener.h"

@class VDependencyManager, VTextToolController;

@interface VTextToolController : VToolController

@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
 *  The default text tool.
 */
@property (nonatomic, assign) NSUInteger defaultTool;

@property (nonatomic, readonly) BOOL canPublish;

@property (nonatomic, strong) id<VTextListener> textListener;

@end
