//
//  VRepostAnimator.h
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VRepostAnimator : NSObject

- (void)updateRepostWithAnimations:(void (^)())animations
                          onButton:(UIButton *)button
                          animated:(BOOL)animated;

@end
