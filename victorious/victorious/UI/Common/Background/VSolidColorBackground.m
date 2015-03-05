//
//  VSolidColorBackground.m
//  victorious
//
//  Created by Michael Sena on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSolidColorBackground.h"
#import "VDependencyManager.h"

NSString * const VSolidColorBackgroundColorKey = @"color";

@interface VSolidColorBackground ()

@property (nonatomic, readwrite) VDependencyManager *dependencyManager;

@property (nonatomic, readwrite) UIColor *backgroundColor;

@end

@implementation VSolidColorBackground

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if (self)
    {
        _backgroundColor = [dependencyManager colorForKey:VSolidColorBackgroundColorKey];
    }
    return self;
}

#pragma mark - Overrides

- (UIView *)viewForBackground
{
    UIView *viewForBackground = [[UIView alloc] initWithFrame:CGRectZero];
    
    viewForBackground.userInteractionEnabled = YES;
    viewForBackground.backgroundColor = self.backgroundColor;
    
    return viewForBackground;
}

@end
