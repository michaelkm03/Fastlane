//
//  VTranslucentBackground.m
//  victorious
//
//  Created by Michael Sena on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTranslucentBackground.h"
#import "VDependencyManager.h"

NSString * const VTranslucentBackgroundBlurStyleKey = @"blurStyleKey";
NSString * const VTranslucentBackgroundBlurStyleExtraLight = @"blurStyleExtraLight";
NSString * const VTranslucentBackgroundBlurStyleLight = @"blurStyleLight";
NSString * const VTranslucentBackgroundBlurStyleDark = @"blurStyleDark";

@interface VTranslucentBackground ()

@property (nonatomic, readwrite) VDependencyManager *dependencyManager;

@property (nonatomic, copy) NSString *blurStyle;

@end

@implementation VTranslucentBackground

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if (self)
    {
        _blurStyle = [dependencyManager stringForKey:VTranslucentBackgroundBlurStyleKey];
    }
    return self;
}

#pragma mark - Overrides

- (UIView *)viewForBackground
{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    containerView.backgroundColor = [UIColor clearColor];
    containerView.userInteractionEnabled = NO;
    
    UIVisualEffectView *viewForBackground = [[UIVisualEffectView alloc] initWithEffect:[self visualEffectForBackground]];
    viewForBackground.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:viewForBackground];
    NSDictionary *viewMap = NSDictionaryOfVariableBindings(viewForBackground);
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[viewForBackground]|"
                                                                          options:kNilOptions
                                                                          metrics:nil
                                                                            views:viewMap]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[viewForBackground]|"
                                                                          options:kNilOptions
                                                                          metrics:nil
                                                                            views:viewMap]];
    return containerView;
}

- (BOOL)isTranslucent
{
    return YES;
}

- (UIBarStyle)barStyleForTranslucentBackground
{
    switch ([self blurEffectStyleForString:self.blurStyle])
    {
        case UIBlurEffectStyleDark:
            return UIBarStyleBlack;
        case UIBlurEffectStyleLight:
        case UIBlurEffectStyleExtraLight:
        default:
            return UIBarStyleDefault;
    }
}

#pragma mark - Private Methods

- (UIVisualEffect *)visualEffectForBackground
{
    return [UIBlurEffect effectWithStyle:[self blurEffectStyleForString:self.blurStyle]];
}

- (UIBlurEffectStyle)blurEffectStyleForString:(NSString *)blurStyle
{
    if ([blurStyle isEqualToString:VTranslucentBackgroundBlurStyleExtraLight])
    {
        return UIBlurEffectStyleExtraLight;
    }
    else if ([blurStyle isEqualToString:VTranslucentBackgroundBlurStyleLight])
    {
        return UIBlurEffectStyleLight;
    }
    else if ([blurStyle isEqualToString:VTranslucentBackgroundBlurStyleDark])
    {
        return UIBlurEffectStyleDark;
    }
    else
    {
        return UIBlurEffectStyleDark;
    }
}

@end
