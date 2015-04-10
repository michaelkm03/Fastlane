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

/**
 A VToolController that handles creating text posts within the workspace.
 */
@interface VTextToolController : VToolController

@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
 *  The default text tool.
 */
@property (nonatomic, assign) NSUInteger defaultTool;

/**
 Indicates whether the text post being created in its current state
 meets all requirements to be published.
 */
@property (nonatomic, readonly) BOOL canPublish;

/**
 An object that can receive updates when the text post is edited.
 */
@property (nonatomic, strong) id<VTextListener> textListener;

@end
