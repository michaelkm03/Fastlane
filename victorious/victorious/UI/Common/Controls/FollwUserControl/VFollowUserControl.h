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

@property (nonatomic) IBInspectable UIImage *followImage;

@property (nonatomic) IBInspectable UIImage *unFollowImage;

@end
