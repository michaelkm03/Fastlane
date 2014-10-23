//
//  VNavigationHeaderView.m
//  victorious
//
//  Created by Will Long on 9/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNavigationHeaderView.h"

#import "VThemeManager.h"
#import "VSettingManager.h"

@interface VNavigationHeaderView ()

@property (nonatomic, weak) IBOutlet UIImageView *headerImageView;
@property (nonatomic, weak) IBOutlet UILabel *headerLabel;
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UIButton *menuButton;
@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (nonatomic, weak, readwrite) IBOutlet UIView<VNavigationSelectorProtocol> *navSelector;
@property (nonatomic) NSInteger lastSelectedControl;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ratioConstraint;

@end

@implementation VNavigationHeaderView

+ (instancetype)menuButtonNavHeaderWithControlTitles:(NSArray *)titles
{
    VNavigationHeaderView *header = [[[NSBundle mainBundle] loadNibNamed:[self preferredNibForTheme] owner:nil options:nil] firstObject];
    header.backButton.hidden = YES;
    header.menuButton.hidden = NO;
    
    [header setupSegmentedControlWithTitles:titles];
    return header;
}

+ (instancetype)backButtonNavHeaderWithControlTitles:(NSArray *)titles
{
    VNavigationHeaderView *header = [[[NSBundle mainBundle] loadNibNamed:[self preferredNibForTheme] owner:nil options:nil] firstObject];
    header.backButton.hidden = NO;
    header.menuButton.hidden = YES;
    
    [header setupSegmentedControlWithTitles:titles];
    return header;
}

+ (NSString *)preferredNibForTheme
{
    if ([[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled])
    {
        return [NSStringFromClass(self) stringByAppendingString:@"-C"];
    }
    else
    {
        return NSStringFromClass(self);
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSString *tintColorKey = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled] ? kVContentTextColor : kVMainTextColor;
    self.menuButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:tintColorKey];
    self.addButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:tintColorKey];
}

- (void)setupSegmentedControlWithTitles:(NSArray *)titles
{
    if (titles.count <= 1)
    {
        [self removeConstraint:self.ratioConstraint];
        self.ratioConstraint = [NSLayoutConstraint constraintWithItem:self
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeHeight
                                                           multiplier:CGRectGetWidth(self.frame) / CGRectGetMinY(self.navSelector.frame)
                                                             constant:0];
        [self addConstraint:self.ratioConstraint];
    }
    else
    {
        self.navSelector.titles = titles;
    }
}

- (void)setDelegate:(id<VNavigationHeaderDelegate>)delegate
{
    _delegate = delegate;
    self.navSelector.delegate = delegate;
}

- (void)setHeaderText:(NSString *)headerText
{
    _headerText = headerText;
    self.headerLabel.text = self.headerText;
}

- (void)updateUI
{
    UIImage *headerImage = [[VThemeManager sharedThemeManager] themedImageForKey:VThemeManagerHomeHeaderImageKey];
    if (self.showHeaderLogoImage && headerImage)
    {
        self.headerImageView.image = headerImage;
        self.headerLabel.hidden = YES;
    }
    else
    {
        self.headerImageView.hidden = YES;
        self.headerLabel.text = self.headerText;
    }
    
    BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
    self.backgroundColor = isTemplateC ? [UIColor whiteColor] : [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];

    NSString *tintColorKey = isTemplateC ? kVContentTextColor : kVMainTextColor;
    
    self.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:tintColorKey];
    self.menuButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:tintColorKey];
    UIImage *image = [self.menuButton.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.menuButton setImage:image forState:UIControlStateNormal];
    
    self.headerLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:tintColorKey];
    
    NSString *headerFontKey = isTemplateC ? kVHeading2Font : kVHeaderFont;
    self.headerLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:headerFontKey];
    self.headerLabel.text = self.headerText;
}

- (IBAction)pressedBack:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(backPressedOnNavHeader:)])
    {
        [self.delegate backPressedOnNavHeader:self];
    }
}

- (IBAction)pressedMenu:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(menuPressedOnNavHeader:)])
    {
        [self.delegate menuPressedOnNavHeader:self];
    }
}

- (void)setRightButtonImage:(UIImage *)image withAction:(SEL)action onTarget:(id)target
{
    self.addButton.hidden = !image;
    [self.addButton setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.addButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

@end
