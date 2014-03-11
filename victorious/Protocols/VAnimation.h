//
//  VAnimation.h
//  victorious
//
//  Created by Will Long on 3/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VAnimation <NSObject>

@required

- (void)animateInWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion;
- (void)animateOutWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion;

@end
