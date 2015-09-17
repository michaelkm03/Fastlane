//
//  VCoachmarkPassthroughContainerView.m
//  victorious
//
//  Created by Sharif Ahmed on 5/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCoachmarkPassthroughContainerView.h"
#import "VCoachmarkView.h"

@interface VCoachmarkPassthroughContainerView ()

@property (nonatomic, readwrite) VCoachmarkView *coachmarkView;

@end

@implementation VCoachmarkPassthroughContainerView

+ (instancetype)coachmarkPassthroughContainerViewWithCoachmarkView:(VCoachmarkView *)coachmarkView andDelegate:(id <VCoachmarkPassthroughContainerViewDelegate>)delegate
{
    NSParameterAssert(coachmarkView != nil);
    
    VCoachmarkPassthroughContainerView *coachmarkPassthroughContainerView = [[VCoachmarkPassthroughContainerView alloc] init];
    coachmarkPassthroughContainerView.coachmarkView = coachmarkView;
    [coachmarkPassthroughContainerView addSubview:coachmarkView];
    coachmarkPassthroughContainerView.delegate = delegate;
    return coachmarkPassthroughContainerView;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *result = [super hitTest:point withEvent:event];
    if ( result == self )
    {
        if ( self.delegate != nil )
        {
            [self.delegate passthroughViewRecievedTouch:self];
        }
        return nil;
    }
    return result;
}

@end