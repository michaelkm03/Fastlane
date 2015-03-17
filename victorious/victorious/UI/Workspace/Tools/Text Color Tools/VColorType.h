//
//  VColorType.h
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VWorkspaceTool.h"

@interface VColorType : NSObject <VWorkspaceTool>

- (instancetype)initWithColor:(UIColor *)color title:(NSString *)title;

@property (nonatomic, readonly) UIColor *color;

@end
