//
//  VExpressionController.h
//  victorious
//
//  Created by Patrick Lynch on 6/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSequence;

@interface VSequenceExpressionsObserver : NSObject

- (void)startObservingWithSequence:(VSequence *)sequence onUpdate:(void(^)())update;

@end
