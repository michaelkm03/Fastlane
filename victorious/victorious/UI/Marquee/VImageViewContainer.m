//
//  VImageViewContainer.m
//  victorious
//
//  Created by Sharif Ahmed on 4/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageViewContainer.h"
#import "UIView+AutoLayout.h"

@implementation VImageViewContainer

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self != nil )
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self != nil )
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.imageView];
    [self v_addFitToParentConstraintsToSubview:self.imageView];
}


@end
