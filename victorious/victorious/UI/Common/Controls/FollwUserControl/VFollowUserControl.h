//
//  VFollowUserControl.h
//  victorious
//
//  Created by Michael Sena on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface VFollowUserControl : UIControl

@property (nonatomic) IBInspectable BOOL following;

- (void)setFollowing:(BOOL)following
            animated:(BOOL)animated;

@end
