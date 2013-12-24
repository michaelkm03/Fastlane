//
//  VMenuViewControllerTransition.h
//  victorious
//
//  Created by David Keegan on 12/24/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

@interface VMenuViewControllerTransition :  NSObject
<UIViewControllerAnimatedTransitioning>
@property (nonatomic) BOOL reverse;
@end

@interface VMenuViewControllerTransitionDelegate : NSObject
<UIViewControllerTransitioningDelegate>
@end

