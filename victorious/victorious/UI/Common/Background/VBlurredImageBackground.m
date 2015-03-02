//
//  VBlurredImageBackground.m
//  victorious
//
//  Created by Michael Sena on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBlurredImageBackground.h"
#import "VDependencyManager.h"
#import "UIImageView+Blurring.h"

NSString *VBlurredImageBackgroundImageToBlurKey = @"VBlurredImageBackgroundImageToBlurKey";
static NSString *const kImageKey;

@interface VBlurredImageBackground ()

@property (nonatomic, strong, readwrite) UIImage *imageToBlur;

@end

@implementation VBlurredImageBackground

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if (self)
    {
        _imageToBlur = [dependencyManager imageForKey:kImageKey];
    }
    return self;
}

#pragma mark - Overrides

- (UIView *)viewForBackground
{
    UIImageView *viewForBackground = [[UIImageView alloc] initWithFrame:CGRectZero];
    viewForBackground.userInteractionEnabled = YES;
    viewForBackground.backgroundColor = [UIColor clearColor];
    [viewForBackground setBlurredImageWithClearImage:self.imageToBlur placeholderImage:nil tintColor:nil];
    return viewForBackground;
}

@end
