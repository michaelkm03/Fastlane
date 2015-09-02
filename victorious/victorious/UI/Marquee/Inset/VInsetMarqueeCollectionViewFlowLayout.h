//
//  VInsetMarqueeCollectionViewFlowLayout.h
//  victorious
//
//  Created by Sharif Ahmed on 6/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    A UICollectionViewFlowLayout subclass that skews cells as they come to be centered on screen
 */
@interface VInsetMarqueeCollectionViewFlowLayout : UICollectionViewFlowLayout

/**
    Calculate and returns the page width for marquee items
    Subclass should overwrite this method if marquee item size is different
 */
- (CGFloat)getPageWidth;

@end
