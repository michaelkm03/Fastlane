//
//  VHamburgerButton.m
//  victorious
//
//  Created by Josh Hinman on 12/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBadgeBackgroundView.h"
#import "VDependencyManager.h"
#import "VBarButton.h"
#import "VNumericalBadgeView.h"

@interface VBarButton ()

@property (nonatomic, weak) IBOutlet UIButton *button;
@property (nonatomic, weak) IBOutlet VNumericalBadgeView *badgeView;
@property (nonatomic, weak) IBOutlet VBadgeBackgroundView *badgeBorder;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VBarButton

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    for (id object in objects)
    {
        if ( [object isKindOfClass:self] )
        {
            ((VBarButton *)object).dependencyManager = dependencyManager;
            return object;
        }
    }
    return nil;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(58.0f, 44.0f);
}

#pragma mark - Properties

- (void)setImage:(UIImage *)image
{
    [self.button setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    
    self.button.enabled = enabled;
    self.button.alpha = enabled ? 1.0f : 0.5f;
}

- (NSInteger)badgeNumber
{
    return self.badgeView.badgeNumber;
}

- (void)setBadgeNumber:(NSInteger)badgeNumber
{
    self.badgeView.hidden = badgeNumber <= 0;
    self.badgeView.badgeNumber = badgeNumber;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    if ( dependencyManager == _dependencyManager )
    {
        return;
    }
    _dependencyManager = dependencyManager;
    
    self.button.tintColor = [dependencyManager colorForKey:VDependencyManagerContentTextColorKey];;
    self.badgeBorder.color = self.backgroundColor;
    self.badgeNumber = 0;
    
    self.badgeView.backgroundColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.badgeView.font = [dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
}

#pragma mark - Target/Action

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self.button addTarget:target action:action forControlEvents:controlEvents];
}

@end
