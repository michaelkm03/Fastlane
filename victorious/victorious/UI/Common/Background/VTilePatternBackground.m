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

static NSString * const kPatternTintColorKey = @"patternTintColor";
static NSString * const kPatternImageKey = @"patternImage";
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
    if (self)
    {
        _patternTintColor = [dependencyManager colorForKey:kPatternTintColorKey];
        _patternImage = [dependencyManager imageForKey:kPatternImageKey];
    }
    return self;
}

- (UIView *)viewForBackground
{
    VTilePatternBackgroundView *tilePatterBackgroundView = [[VTilePatternBackgroundView alloc] initWithFrame:CGRectZero];
    
    tilePatterBackgroundView.patternTintColor = self.patternTintColor;
    tilePatterBackgroundView.patternImage = self.patternImage;
    tilePatterBackgroundView.tiltParallaxEnabled = self.tiltParallaxEnabled;
    tilePatterBackgroundView.shimmerAnimationActive = self.shimmerAnimationActive;
    
    return tilePatterBackgroundView;
}

@end
