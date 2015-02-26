//
//  VHamburgerButton.m
//  victorious
//
//  Created by Josh Hinman on 12/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBadgeBackgroundView.h"
#import "VDependencyManager.h"
#import "VHamburgerButton.h"
#import "VNumericalBadgeView.h"

NSString * const VHamburgerButtonIconKey = @"menuIcon";

@interface VHamburgerButton ()

@property (nonatomic, weak) IBOutlet UIButton *hamburgerButton;
@property (nonatomic, weak) IBOutlet VNumericalBadgeView *badgeView;
@property (nonatomic, weak) IBOutlet VBadgeBackgroundView *badgeBorder;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VHamburgerButton

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    for (id object in objects)
    {
        if ( [object isKindOfClass:self] )
        {
            ((VHamburgerButton *)object).dependencyManager = dependencyManager;
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

- (NSInteger)badgeNumber
{
    return self.badgeView.badgeNumber;
}

- (void)setBadgeNumber:(NSInteger)badgeNumber
{
    self.badgeView.badgeNumber = badgeNumber;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    if ( dependencyManager == _dependencyManager )
    {
        return;
    }
    _dependencyManager = dependencyManager;
    
    UIColor *tintColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    
    self.hamburgerButton.tintColor = tintColor;
    self.badgeBorder.color = self.backgroundColor;
    
    UIImage *image = [[self.dependencyManager imageForKey:VHamburgerButtonIconKey] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.hamburgerButton setImage:image forState:UIControlStateNormal];
    
    self.badgeView.font = [dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
}

#pragma mark - Target/Action

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self.hamburgerButton addTarget:target action:action forControlEvents:controlEvents];
}

@end
