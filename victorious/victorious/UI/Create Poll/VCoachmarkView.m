//
//  VCoachmarkView.m
//  victorious
//
//  Created by Sharif Ahmed on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCoachmarkView.h"
#import "VCoachmark.h"

@interface VCoachmarkView ()

@property (nonatomic, strong) UIView *backgroundContainerView;

@end

@implementation VCoachmarkView

+ (instancetype)coachmarkViewWithCoachmark:(VCoachmark *)coachmark center:(CGPoint)center targetPoint:(CGPoint)targetPoint
{
    VCoachmarkView *coachmarkView = [[VCoachmarkView alloc] init];
#warning Setup the coachmark view here
    coachmarkView.backgroundColor = [UIColor redColor];
    coachmarkView.frame = CGRectMake(0, 0, 200, 200);
    
    
    return coachmarkView;
}

@end
