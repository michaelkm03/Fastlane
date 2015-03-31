//
//  VTilePatternBackground.m
//  victorious
//
//  Created by Michael Sena on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTilePatternBackground.h"

// Views
#import "VTilePatternBackgroundView.h"

// Dependencies
#import "VDependencyManager.h"

static NSString * const kPatternTintColorKey = @"color";
static NSString * const kPatternImageKey = @"image";
@interface VTilePatternBackground ()

@property (nonatomic, copy) UIColor *patternTintColor;
@property (nonatomic, strong) UIImage *patternImage;
@property (nonatomic, assign) BOOL tiltParallaxEnabled;
@property (nonatomic, assign) BOOL shimmerAnimationActive;

@end

@implementation VTilePatternBackground

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if (self != nil)
    {
        _patternTintColor = [dependencyManager colorForKey:kPatternTintColorKey];
        _patternImage = [dependencyManager imageForKey:kPatternImageKey];
    }
    return self;
}

- (UIView *)viewForBackground
{
    VTilePatternBackgroundView *tilePatternBackgroundView = [[VTilePatternBackgroundView alloc] initWithFrame:CGRectZero];
    
    tilePatternBackgroundView.color = self.patternTintColor;
    tilePatternBackgroundView.image = self.patternImage;
    tilePatternBackgroundView.tiltParallaxEnabled = self.tiltParallaxEnabled;
    tilePatternBackgroundView.shimmerAnimationActive = self.shimmerAnimationActive;
    
    return tilePatternBackgroundView;
}

@end
