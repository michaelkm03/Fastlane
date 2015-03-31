//
//  VTextToolController.h
//  victorious
//
//  Created by Patrick Lynch on 3/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VToolController.h"

@class VDependencyManager, VTextToolController;

@protocol VTextToolControllerDelegate <NSObject>

- (void)textDidUpdate:(NSString *)text;

@end

@interface VTextToolController : VToolController

@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
 *  The default text tool.
 */
@property (nonatomic, assign) NSUInteger defaultTool;

@property (nonatomic, strong) NSString *text;

@property (nonatomic, strong) NSString *hashtagText;

@property (nonatomic, strong) id<VTextToolControllerDelegate> textToolDelegate;

@end
