//
//  VSettingsSwitchCell.m
//  victorious
//
//  Created by Patrick Lynch on 11/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VSettingsSwitchCell.h"

NS_ASSUME_NONNULL_BEGIN

NSString * const itemBackgroundColorKey = @"color.background.navigation.items";
NSString * const itemTextFontKey = @"font.text.navigation.items";
NSString * const itemTextColorKey = @"color.text.navigation.items";

@interface VSettingsSwitchCell()

@property (strong, nonatomic) IBOutlet UILabel *settingLabel;
@property (strong, nonatomic) IBOutlet UISwitch *settingSwitch;

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, assign) BOOL shouldPreventNotifyingDelegate;

@end

@implementation VSettingsSwitchCell

+ (NSString *)suggestedReuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    self.settingLabel.font =  [dependencyManager fontForKey: itemTextFontKey];
    self.settingLabel.textColor = [dependencyManager colorForKey:itemTextColorKey];
    self.backgroundColor = [dependencyManager colorForKey:itemBackgroundColorKey];
}

- (void)setTitle:(NSString *)title value:(BOOL)value
{
    self.settingLabel.text = title;
    self.settingSwitch.on = value;
}

- (BOOL)value
{
    return self.settingSwitch.on;
}

- (void)setValue:(BOOL)value animated:(BOOL)animated
{
    self.shouldPreventNotifyingDelegate = YES;
    [self.settingSwitch setOn:value animated:animated];
    self.shouldPreventNotifyingDelegate = NO;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.shouldPreventNotifyingDelegate = NO;
}

#pragma mark - Actions

- (IBAction)settingValueDidchange:(UISwitch *)settingSwitch
{
    if ( !self.shouldPreventNotifyingDelegate &&
         self.delegate != nil &&
         [self.delegate respondsToSelector:@selector(settingsDidUpdateFromCell:newValue:key:)] )
    {
        [self.delegate settingsDidUpdateFromCell:self newValue:[self value] key:[self key]];
    }
}

@end

NS_ASSUME_NONNULL_END