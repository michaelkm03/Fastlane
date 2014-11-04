//
//  VSegmentedNavSelector.m
//  victorious
//
//  Created by Will Long on 10/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSegmentedNavSelector.h"

#import "VThemeManager.h"

#import "VNavigationHeaderView.h"

@implementation VSegmentedNavSelector

@synthesize lastIndex = _lastIndex;
@synthesize titles = _titles;
@synthesize delegate = _delegate;
@synthesize currentIndex = _currentIndex;

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self commonInit];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.segmentedControl = [[UISegmentedControl alloc] initWithFrame:self.bounds];
    [self.segmentedControl addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
    
    [self addSubview:self.segmentedControl];
    
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

- (void)valueChanged
{
    self.currentIndex = self.segmentedControl.selectedSegmentIndex;
}

- (void)setTitles:(NSArray *)titles
{
    [self.segmentedControl removeAllSegments];
    for (NSUInteger i = 0; i < titles.count; i++)
    {
        [self.segmentedControl insertSegmentWithTitle:titles[i] atIndex:i animated:NO];
    }
    _titles = titles;
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    BOOL shouldChange = YES;
    if ([self.delegate respondsToSelector:@selector(navSelector:changedToIndex:)])
    {
        shouldChange = [self.delegate navSelector:self changedToIndex:currentIndex];
    }
    
    if (!shouldChange)
    {
        [self.segmentedControl setSelectedSegmentIndex:_currentIndex];
    }
    else
    {
        self.lastIndex = _currentIndex;
        _currentIndex = currentIndex;
        [self.segmentedControl setSelectedSegmentIndex:currentIndex];
    }
}

@end
