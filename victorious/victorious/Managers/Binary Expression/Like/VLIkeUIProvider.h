//
//  VLikeUIProvider.h
//  victorious
//
//  Created by Patrick Lynch on 6/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

#import "VBinaryExpressionControl.h"
#import "VBinaryExpressionCountDisplay.h"

@protocol VLikeUIProvider <NSObject>

@property (nonatomic, strong, readonly) UIControl<VBinaryExpressionControl> *control;

@property (nonatomic, strong, readonly) UIControl<VBinaryExpressionCountDisplay> *countDisplay;

@end