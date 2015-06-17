//
//  VExpressionControl.m
//  victorious
//
//  Created by Patrick Lynch on 6/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamLikeButton.h"
#import "VLargeNumberFormatter.h"

@interface VStreamLikeButton()

@property (nonatomic, strong) UIImage *unselectedImage;
@property (nonatomic, strong) UIImage *selectedImage;

@end

@implementation VStreamLikeButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.unselectedImage = [[UIImage imageNamed:@"like"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.selectedImage = [[UIImage imageNamed:@"like_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [self setActive:NO];
}

- (void)setActive:(BOOL)active
{
    UIImage *image = active ? self.selectedImage : self.unselectedImage;
    [self setImage:image forState:UIControlStateNormal];
    [self sizeToFit];
}

@end
