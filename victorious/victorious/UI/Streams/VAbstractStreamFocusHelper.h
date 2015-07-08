//
//  VStreamFocusHelper.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VAbstractStreamFocusHelper : NSObject

- (void)updateFocusWithScrollView:(UIScrollView *)scrollView visibleCells:(NSArray *)visibleCells;
- (void)manuallyEndFocusOnCell:(UIView *)cell;

@end
