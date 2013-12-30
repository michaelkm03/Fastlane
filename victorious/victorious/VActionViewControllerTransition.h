//
//  VActionViewControllerTransition.h
//  victorious
//
//  Created by David Keegan on 12/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

@interface VActionViewControllerTransition :  NSObject
<UIViewControllerAnimatedTransitioning>
@property (nonatomic) BOOL reverse;
@end

@interface VActionViewControllerTransitionDelegate : NSObject
<UIViewControllerTransitioningDelegate>
@end
