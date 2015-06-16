//
//  VExpressionController.h
//  victorious
//
//  Created by Patrick Lynch on 6/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VBinaryExpressionControl.h"
#import "VBinaryExpressionCountDisplay.h"

@class VSequence;

@interface VLikeController : NSObject

- (void)startObservingWithSequence:(VSequence *)sequence
                           control:(UIControl<VBinaryExpressionControl> *)control
                      countDisplay:(id<VBinaryExpressionCountDisplay>)countDisplay;

- (void)stopObserving;

@end
