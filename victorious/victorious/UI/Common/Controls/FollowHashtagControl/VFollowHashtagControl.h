//
//  VFollowHashtagControl.h
//  victorious
//
//  Created by Lawrence Leach on 12/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface VFollowHashtagControl : UIControl

@property (nonatomic) IBInspectable BOOL subscribed;
@property (nonatomic, readwrite) BOOL shouldRespondToTap;

- (void)setSubscribed:(BOOL)subscribed
             animated:(BOOL)animated;

@end
