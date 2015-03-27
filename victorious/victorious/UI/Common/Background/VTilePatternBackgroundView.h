//
//  VLoadingView.h
//  victorious
//
//  Created by Michael Sena on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VTilePatternBackgroundView : UIView

@property (nonatomic, copy) UIColor *patternTintColor;
@property (nonatomic, strong) UIImage *patternImage;
@property (nonatomic, assign) BOOL tiltParallaxEnabled;
@property (nonatomic, assign) BOOL shimmerAnimationActive;

@end
