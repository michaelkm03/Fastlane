//
//  VStreamsSubViewController.h
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VKeyboardBarContainerViewController.h"

#import "VAnimation.h"

@class VSequence, VDependencyManager;

@interface VCommentsContainerViewController : VKeyboardBarContainerViewController <VAnimation>
@property (nonatomic, strong) VSequence *sequence;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
