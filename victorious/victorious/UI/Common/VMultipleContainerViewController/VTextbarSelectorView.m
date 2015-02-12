//
//  VTextbarSelectorView.m
//  victorious
//
//  Created by Sharif Ahmed on 2/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextbarSelectorView.h"

@implementation VTextbarSelectorView

- (void)setViewControllers:(NSArray *)viewControllers
{
    [super setViewControllers:viewControllers];
    [self setup];
}

- (void)setup
{
    [self setBackgroundColor:[UIColor greenColor]];
}

@end
