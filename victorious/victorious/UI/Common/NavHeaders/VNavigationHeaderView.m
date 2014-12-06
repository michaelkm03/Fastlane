//
//  VNavigationHeaderView.m
//  victorious
//
//  Created by Will Long on 9/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNavigationHeaderView.h"
#import "VBadgeLabel.h"
#import "VThemeManager.h"
#import "VSettingManager.h"
#import "VAutomation.h"

@interface VNavigationHeaderView ()

@property (nonatomic, weak) IBOutlet UIImageView *headerImageView;
@property (nonatomic, weak) IBOutlet UILabel *headerLabel;
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UIButton *menuButton;
@property (nonatomic, weak) IBOutlet VBadgeLabel *badgeLabel;
@property (nonatomic, weak) IBOutlet UIView *badgeBorder;
@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (nonatomic, weak, readwrite) IBOutlet UIView<VNavigationSelectorProtocol> *navSelector;
@property (nonatomic) NSInteger lastSelectedControl;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ratioConstraint;

@end

static NSInteger _badgeNumber = 0; // I am SO SORRY about how hacky this is. I promise I'll fix it soon.

@implementation VNavigationHeaderView

+ (instancetype)menuButtonNavHeaderWithControlTitles:(NSArray *)titles
{
    NSString *nibName = [VHeaderView preferredNibForThemeForClass:[self class]];
    VNavigationHeaderView *header = [[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil] firstObject];
    header.backButton.hidden = YES;
    header.menuButton.hidden = NO;
    
    [header setupSegmentedControlWithTitles:titles];
    return header;
}

+ (instancetype)backButtonNavHeaderWithControlTitles:(NSArray *)titles
{
    NSString *nibName = [VHeaderView preferredNibForThemeForClass:[self class]];
    VNavigationHeaderView *header = [[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil] firstObject];
    header.backButton.hidden = NO;
    header.menuButton.hidden = YES;
    
    [header setupSegmentedControlWithTitles:titles];
    return header;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backButton.accessibilityIdentifier = VAutomationIdentifierGenericBack;
    self.menuButton.accessibilityIdentifier = VAutomationIdentifierMainMenu;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ( CGRectGetHeight(self.badgeLabel.frame) == 0 || CGRectGetWidth(self.badgeLabel.frame) == 0 )
    {
        self.badgeBorder.bounds = CGRectZero;
    }
}

- (void)applyTheme
{
    BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
    NSString *tintColorKey = isTemplateC ? kVContentTextColor : kVMainTextColor;
    UIColor *tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:tintColorKey];
    
    self.tintColor = tintColor;
    self.backButton.tintColor = tintColor;
    [self.backButton setTitleColor:tintColor forState:UIControlStateNormal];
    self.menuButton.tintColor = tintColor;
    [self.menuButton setTitleColor:tintColor forState:UIControlStateNormal];
    self.addButton.tintColor = tintColor;
    [self.addButton setTitleColor:tintColor forState:UIControlStateNormal];
    
    self.backgroundColor = isTemplateC ? [UIColor whiteColor] : [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.badgeBorder.backgroundColor = self.backgroundColor;
    
    UIImage *image = [self.menuButton.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.menuButton setImage:image forState:UIControlStateNormal];
    
    image = [self.backButton.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.backButton setImage:image forState:UIControlStateNormal];
    
    self.headerLabel.textColor = tintColor;
    
    NSString *headerFontKey = isTemplateC ? kVHeading2Font : kVHeaderFont;
    self.headerLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:headerFontKey];
    self.headerLabel.text = self.headerText;
    
    self.badgeLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
    [self setBadgeNumber:_badgeNumber];
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
        
        CGRect frame = self.frame;
        frame.size.height = CGRectGetMinY(self.navSelector.frame);
        self.frame = frame;
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

- (void)setShowHeaderLogoImage:(BOOL)showHeaderLogoImage
{
    _showHeaderLogoImage = showHeaderLogoImage;
    [self updateHeaderImage];
}

- (void)updateUIForVC:(UIViewController *)viewController
{
    [self updateHeaderImage];
    
    if (viewController.navigationController.viewControllers.count <= 1)
    {
        self.backButton.hidden = YES;
        self.menuButton.hidden = NO;
    }
    else
    {
        self.backButton.hidden = NO;
        self.menuButton.hidden = YES;
    }
}

- (void)updateHeaderImage
{
    UIImage *headerImage = [[VThemeManager sharedThemeManager] themedImageForKey:VThemeManagerHomeHeaderImageKey];
    if (self.showHeaderLogoImage && headerImage)
    {
        self.headerImageView.image = headerImage;
        self.headerImageView.hidden = NO;
        self.headerLabel.hidden = YES;
    }
    else
    {
        self.headerImageView.hidden = YES;
        self.headerLabel.text = self.headerText;
    }
    
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

- (UIButton *)setRightButtonImage:(UIImage *)image withAction:(SEL)action onTarget:(id)target
{
    self.addButton.hidden = !image;
    [self.addButton setTitle:@"" forState:UIControlStateNormal];
    [self.addButton setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.addButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return self.addButton;
}

- (UIButton *)setRightButtonTitle:(NSString *)title withAction:(SEL)action onTarget:(id)target
{
    self.addButton.hidden = !title;
    [self.addButton setImage:nil forState:UIControlStateNormal];
    [self.addButton setTitle:title forState:UIControlStateNormal];
    [self.addButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return self.addButton;
}

- (void)setBadgeNumber:(NSInteger)badgeNumber
{
    _badgeNumber = badgeNumber;
    [self.badgeLabel setBadgeNumber:badgeNumber];
}

@end
