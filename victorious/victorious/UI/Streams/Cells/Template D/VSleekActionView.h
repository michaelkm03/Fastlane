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

@property (nonatomic, strong, readonly) VSleekActionButton *commentButton;
@property (nonatomic, strong, readonly) VSleekActionButton *repostButton;
@property (nonatomic, strong, readonly) VSleekActionButton *memeButton;
@property (nonatomic, strong, readonly) VSleekActionButton *gifButton;
@property (nonatomic, strong, readonly) VSleekActionButton *likeButton;

@property (nonatomic) CGFloat leftMargin;

@end
