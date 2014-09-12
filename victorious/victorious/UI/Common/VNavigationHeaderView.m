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

@end

@implementation VNavigationHeaderView

+ (instancetype)menuButtonNavHeaderWithControlTitles:(NSArray *)titles
{
    VNavigationHeaderView *header = [[VNavigationHeaderView alloc] init];
    header.backButton.hidden = YES;
    header.menuButton.hidden = NO;
    
    [header initSegmentedControlWithTitles:titles];
    return header;
}

+ (instancetype)backButtonNavHeaderWithControlTitles:(NSArray *)titles
{
    VNavigationHeaderView *header = [[VNavigationHeaderView alloc] init];
    header.backButton.hidden = NO;
    header.menuButton.hidden = YES;
    
    [header initSegmentedControlWithTitles:titles];
    return header;
}

- (void)initSegmentedControlWithTitles:(NSArray *)titles
{
    if (!titles.count)
    {
        self.segmentedControl.hidden = YES;
        CGRect newBounds = self.bounds;
        newBounds.size.height = CGRectGetMinY(self.segmentedControl.frame);
        self.bounds = newBounds;
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

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    
    for (UIButton* button in @[self.menuButton, self.addButton, self.backButton])
    {
        button.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
        UIImage* image = [button.currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [button setImage:image forState:UIControlStateNormal];
    }
        
    self.headerLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    self.headerLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    
    [self configureSegmentedControl];
}

- (void)configureSegmentedControl
{
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
    if ([self.delegate respondsToSelector:@selector(backButtonPressed)])
    {
        [self.delegate backButtonPressed];
    }
}

- (IBAction)pressedMenu:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(menuButtonPressed)])
    {
        [self.delegate menuButtonPressed];
    }
}

- (IBAction)pressedAdd:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(addButtonPressed)])
    {
        [self.delegate addButtonPressed];
    }
}

- (void)setShowAddButton:(BOOL)showAddButton
{
    _showAddButton = showAddButton;
    self.addButton.hidden = YES;
}

@end
