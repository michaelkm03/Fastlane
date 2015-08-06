//
//  VTabMenuButtonTap.h
//  victorious
//
//  Created by Tian Lan on 8/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 
 Viewcontrollers conform to this protocol will have its stream scroll to top
 when the same tab menu button is being tapped again
 */
@protocol VTabMenuButtonTap <NSObject>
/**
 Scrolls stream content to top by 
 setting contentOffset to CGPointZero
 */
- (void)scrollContentToTop;

@end
