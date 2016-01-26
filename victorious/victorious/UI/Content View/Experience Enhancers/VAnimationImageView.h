//
//  VAnimationImageView.h
//  victorious
//
//  Created by Vincent Ho on 1/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ANIMATION_IMAGE_VIEW_MEMORY_WARNING_STOP @"ANIMATION_IMAGE_VIEW_MEMORY_WARNING_STOP"

@class VAnimationImageView;

@protocol VAnimationImageViewDelegate <NSObject>
-(void)animation:(VAnimationImageView *)animation didFinishAnimating:(BOOL)completed;
@end

@interface VAnimationImageView : NSObject

//If flight image != nil, then it is ballistic
@property (nonatomic, strong) UIImage * flightImage;
@property (nonatomic, strong) NSArray * animationSequence;
@property (nonatomic, weak) id delegate;
@property (nonatomic) CGFloat animationDuration;
@property (nonatomic) UIViewContentMode contentMode;

-(instancetype)initWithFrame:(CGRect)frame;

//    For ballistics
-(void)startFlightFor:(NSTimeInterval)flightDuration on:(UIView *)view center:(CGPoint)center frame:(CGRect)frame;

//    Start animation with limitations on concurrent animations
-(void)startAnimatingOn:(UIView *)view withSemaphore:(dispatch_semaphore_t) sem;

-(void)startAnimatingOn:(UIView *)view;

-(void)stopAnimating;

@end
