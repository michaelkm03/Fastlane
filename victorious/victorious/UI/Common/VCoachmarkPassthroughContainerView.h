//
//  VCoachmarkPassthroughContainerView.h
//  victorious
//
//  Created by Sharif Ahmed on 5/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCoachmarkPassthroughContainerViewDelegate.h"

#warning DOCS, TESTS INCOMPLETE

@class VCoachmarkView;

@interface VCoachmarkPassthroughContainerView : UIView

+ (instancetype)coachmarkPassthroughContainerViewWithCoachmarkView:(VCoachmarkView *)coachmarkView frame:(CGRect)frame andDelegate:(id <VCoachmarkPassthroughContainerViewDelegate>)delegate;

@property (nonatomic, weak) id <VCoachmarkPassthroughContainerViewDelegate> delegate;
@property (nonatomic, readonly) VCoachmarkView *coachmarkView;

@end
