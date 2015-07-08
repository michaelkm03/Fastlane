//
//  VStreamFocusHelper.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VStreamFocusHelper : NSObject

@property (nonatomic, assign) CGFloat visibilityRatio;

- (void)updateFocus;
- (void)endFocusOnCell:(UIView *)cell;
- (void)endFocusOnAllCells;

// Methods to override
- (UIScrollView *)scrollView;
- (NSArray *)visibleCells;

@end
