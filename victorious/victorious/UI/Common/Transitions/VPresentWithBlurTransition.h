//
//  VPresentWithBlurTransition.h
//  victorious
//
//  Created by Patrick Lynch on 3/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

#import "VAnimatedTransition.h"

@protocol VPresentWithBlurViewController <NSObject>

@property (nonatomic, strong) UIView *blurredBackgroundView;
@property (nonatomic, strong) NSOrderedSet *stackedElements;

@end

@interface VPresentWithBlurTransition : NSObject <VAnimatedTransition>

@end
