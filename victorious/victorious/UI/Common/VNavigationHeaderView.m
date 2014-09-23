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
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
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
        self.heightConstraint.constant = CGRectGetMinY(self.segmentedControl.frame);
    }
    else
    {
        [self.segmentedControl removeAllSegments];
        for (NSUInteger i = 0; i < titles.count; i++)
        {
            [self.segmentedControl insertSegmentWithTitle:titles[i] atIndex:i animated:NO];
        }
    }
}

- (void)updateUI
{
    self.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    
    self.menuButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    UIImage *image = [self.menuButton.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.menuButton setImage:image forState:UIControlStateNormal];
    
    self.headerLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    self.headerLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    
    self.segmentedControl.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    self.segmentedControl.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor];
    self.segmentedControl.layer.cornerRadius = 4;
    self.segmentedControl.clipsToBounds = YES;
    
    [self.segmentedControl setDividerImage:[UIImage imageNamed:@"segmentedControlSeperatorLeftUnselected"]
                     forLeftSegmentState:UIControlStateNormal
                       rightSegmentState:UIControlStateSelected
                              barMetrics:UIBarMetricsDefault];
    [self.segmentedControl setDividerImage:[UIImage imageNamed:@"segmentedControlSeperatorRightUnselected"]
                     forLeftSegmentState:UIControlStateSelected
                       rightSegmentState:UIControlStateNormal
                              barMetrics:UIBarMetricsDefault];
    [self.segmentedControl setBackgroundImage:[UIImage imageNamed:@"segmentedControlBorderUnselected"]
                                   forState:UIControlStateNormal
                                 barMetrics:UIBarMetricsDefault];
    [self.segmentedControl setBackgroundImage:[UIImage imageNamed:@"segmentedControlBorderSelected"]
                                   forState:UIControlStateSelected
                                   barMetrics:UIBarMetricsDefault];
    [self.segmentedControl setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:12]}
                                       forState:UIControlStateNormal];
    [self.segmentedControl setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:12],
                                                  NSForegroundColorAttributeName: [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor]}
                                       forState:UIControlStateSelected];
}

- (void)showHeaderLogo
{
    UIImage *headerImage = [[VThemeManager sharedThemeManager] themedImageForKey:VThemeManagerHomeHeaderImageKey];
    if (headerImage)
    {
        self.headerImageView.image = headerImage;
        self.headerLabel.hidden = YES;
    }
    else
    {
        self.headerImageView.hidden = YES;
    }
}

- (IBAction)changedFilterControls:(id)sender
{
    BOOL shouldChange = YES;
    if ([self.delegate respondsToSelector:@selector(segmentControlChangeToIndex:)])
    {
        shouldChange = [self.delegate segmentControlChangeToIndex:self.segmentedControl.selectedSegmentIndex];
    }
    if (!shouldChange)
    {
        [self.segmentedControl setSelectedSegmentIndex:self.lastSelectedControl];
    }
    else
    {
        self.lastSelectedControl = self.segmentedControl.selectedSegmentIndex;
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

- (IBAction)pressedAdd:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(addPressedOnNavHeader:)])
    {
        [self.delegate addPressedOnNavHeader:self];
    }
}

- (void)setShowAddButton:(BOOL)showAddButton
{
    _showAddButton = showAddButton;
    self.addButton.hidden = YES;
}

@end
