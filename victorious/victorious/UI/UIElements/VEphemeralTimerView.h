//
//  VEphemeralTimerView.h
//  victorious
//
//  Created by Will Long on 3/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VEphemeralTimerViewDelegate <NSObject>
@required
- (void)contentExpired;
@end

@interface VEphemeralTimerView : UIView

@property (nonatomic) NSUInteger timerWidth;
@property (strong, nonatomic) UIColor* timerColor;
@property (copy, nonatomic) NSDate* expireDate;

@property (weak, nonatomic) id<VEphemeralTimerViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame expireDate:(NSDate*)expireDate delegate:(id<VEphemeralTimerViewDelegate>)delegate;

@end
