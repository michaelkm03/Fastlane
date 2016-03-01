//
//  VSleekActionView.h
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VAbstractActionView.h"
#import "VHasManagedDependencies.h"
#import "VSleekActionButton.h"

extern CGFloat const VActionButtonHeight;

/**
 *  An VAbstractActionView for sleek cells.
 */
@interface VSleekActionView : VAbstractActionView <VHasManagedDependencies>

/**
    Provides the space between the horizontal edge of the action view and the button
        closest to the horizontal edge based on the width of the action view.
 
    @param width The width of the entire action view.
 
    @return The distance between the horizontal edge of the action view and the button
        closest to the horizontal edge.
 */
+ (CGFloat)outerMarginForBarWidth:(CGFloat)width;

@property (nonatomic, strong, readonly) VSleekActionButton *commentButton;
@property (nonatomic, strong, readonly) VSleekActionButton *repostButton;
@property (nonatomic, strong, readonly) VSleekActionButton *likeButton;
@property (nonatomic, strong, readonly) VSleekActionButton *moreButton;

@property (nonatomic) CGFloat leftMargin;

@end
