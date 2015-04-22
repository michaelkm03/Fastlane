//
//  VRoundedCommentButton.m
//  victorious
//
//  Created by Michael Sena on 4/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VRoundedCommentButton.h"

// Dependencies
#import "VDependencyManager.h"

// Helpers
#import "UIView+AutoLayout.h"

static CGFloat const kCommentWidth = 68.0f;
static CGFloat const kActionButtonHeight = 31.0f;

@implementation VRoundedCommentButton

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    [self setImage:[UIImage imageNamed:@"D_commentIcon"] forState:UIControlStateNormal];
}

#pragma mark - UIView

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(kCommentWidth, kActionButtonHeight);
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    self.unselectedColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
}

@end
