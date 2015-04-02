//
//  VColorType.h
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VWorkspaceTool.h"

/**
 A workspace tool that representes an available color option to be
 displayed in a tool picker inspector view.
 */
@interface VColorType : NSObject <VWorkspaceTool>

/**
 The designated initializer that accepts required values for color and title, i.e. the name of the color provided
 that will be displayed in a picker.
 */
- (instancetype)initWithColor:(UIColor *)color title:(NSString *)title NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) UIColor *color;

@end
