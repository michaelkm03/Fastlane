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

@interface VSettingsSwitchCell()

@property (nonatomic, strong) IBOutlet UISwitch *settingSwitch;
@property (nonatomic, strong) IBOutlet UILabel *settingLabel;
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
    
    self.settingLabel.font = [dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
    self.settingSwitch.onTintColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
}

- (void)setTitle:(NSString *)title value:(BOOL)value
{
    self.settingLabel.text = title;
    self.settingSwitch.on = value;
}

- (void)setSwitchColor:(UIColor *__nonnull)switchColor
{
    _switchColor = switchColor;
    self.settingSwitch.onTintColor = switchColor;
}

- (BOOL)value
{
    return self.settingSwitch.on;
}

-(NSString *) key
{
    return self.key
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
         [self.delegate respondsToSelector:@selector(settingsDidUpdateFromCell:)] )
    {
        [self.delegate settingsDidUpdateFromCell:self newValue:[self value] key:[self key]];
    }
}

@end

NS_ASSUME_NONNULL_END