//
//  VNavigationHeaderView.m
//  victorious
//
//  Created by Will Long on 9/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNavigationHeaderView.h"

#import "VThemeManager.h"

@interface VNavigationHeaderView ()

@property (nonatomic, weak) IBOutlet UIImageView *headerImageView;
@property (nonatomic, weak) IBOutlet UILabel *headerLabel;
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UIButton *menuButton;
@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (nonatomic, weak, readwrite) IBOutlet UIView<VNavigationSelectorProtocol> *navSelector;
@property (nonatomic) NSInteger lastSelectedControl;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *heightConstraint;

@end

@implementation VNavigationHeaderView

+ (instancetype)menuButtonNavHeaderWithControlTitles:(NSArray *)titles
{
    VNavigationHeaderView *header = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] firstObject];
    header.backButton.hidden = YES;
    header.menuButton.hidden = NO;
    
    [header setupSegmentedControlWithTitles:titles];
    return header;
}

+ (instancetype)backButtonNavHeaderWithControlTitles:(NSArray *)titles
{
    VNavigationHeaderView *header = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] firstObject];
    header.backButton.hidden = NO;
    header.menuButton.hidden = YES;
    
    [header setupSegmentedControlWithTitles:titles];
    return header;
}

- (void)setupSegmentedControlWithTitles:(NSArray *)titles
{
    if (!titles.count)
    {
        self.heightConstraint.constant = CGRectGetMinY(self.navSelector.frame);
    }
    else
    {
        self.navSelector.titles = titles;
    }
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
    
    self.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    
    self.menuButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    UIImage *image = [self.menuButton.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.menuButton setImage:image forState:UIControlStateNormal];
    
    self.headerLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    self.headerLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.headerLabel.text = self.headerText;
}

- (void)navSelector:(UIView<VNavigationSelectorProtocol> *)selector selectedIndex:(NSInteger)index
{
    BOOL shouldChange = YES;
    if ([self.delegate respondsToSelector:@selector(navHeaderView:segmentControlChangeToIndex:)])
    {
        shouldChange = [self.delegate navHeaderView:self segmentControlChangeToIndex:index];
    }
    if (!shouldChange)
    {
        self.navSelector.currentIndex = self.lastSelectedControl;
    }
    else
    {
        self.lastSelectedControl = index;
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

- (void)setRightButtonImage:(UIImage *)image withAction:(SEL)action onTarget:(id)target
{
    self.addButton.hidden = !image;
    [self.addButton setImage:image forState:UIControlStateNormal];
    [self.addButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

@end
