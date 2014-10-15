//
//  VSwipeNavSelector.m
//  victorious
//
//  Created by Will Long on 10/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSwipeNavSelector.h"

#import "VThemeManager.h"

static CGFloat const kVIndicatorViewHeight = 3;

@interface VSwipeNavSelector()

@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *titleButtons;
@property (nonatomic) CGFloat spacing;

@end

@implementation VSwipeNavSelector

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
    self.layer.borderColor = [[[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryLinkColor] colorWithAlphaComponent:.1].CGColor;
    self.layer.borderWidth = 1;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.contentInset = UIEdgeInsetsMake(0, CGRectGetWidth(self.bounds)/2, 0, CGRectGetWidth(self.bounds)/2);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;

    [self addSubview:self.scrollView];
    
    self.spacing = 55;
    
    self.indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, kVIndicatorViewHeight)];
    self.indicatorView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryLinkColor];
//    self.widthConstraint = [NSLayoutConstraint constraintWithItem:self.indicatorView
//                                                        attribute:NSLayoutAttributeWidth
//                                                        relatedBy:NSLayoutRelationEqual
//                                                           toItem:nil
//                                                        attribute:NSLayoutAttributeNotAnAttribute
//                                                       multiplier:1.0
//                                                         constant:10];
//    NSLayoutConstraint *centerConstraint = [NSLayoutConstraint constraintWithItem:self.indicatorView
//                                                                        attribute:NSLayoutAttributeCenterX
//                                                                        relatedBy:NSLayoutRelationEqual
//                                                                           toItem:self
//                                                                        attribute:NSLayoutAttributeCenterX
//                                                                       multiplier:1.0
//                                                                         constant:0];
    [self addSubview:self.indicatorView];
//    [self addConstraints:@[centerConstraint, self.widthConstraint]];
}

- (void)valueChanged
{
    if ([self.delegate respondsToSelector:@selector(navSelector:selectedIndex:)])
    {
//        [self.delegate navSelector:self selectedIndex:self.segmentedControl.selectedSegmentIndex];
    }
}

- (void)setTitles:(NSArray *)titles
{
    for (UIButton *button in self.titleButtons)
    {
        [button removeFromSuperview];
    }
    
    UIFont *font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
    NSMutableArray *newTitleButtons = [[NSMutableArray alloc] initWithCapacity:titles.count];
    CGFloat xOffset = 0;
    for (NSUInteger i = 0; i < titles.count; i++)
    {
        NSString *title = titles[i];
        
        CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName:font}];
        UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        titleButton.tag = i;
        CGFloat yOffset = (CGRectGetHeight(self.scrollView.frame)- titleSize.height) / 2;
        titleButton.frame = CGRectMake(xOffset, yOffset, titleSize.width, titleSize.height);
        titleButton.titleLabel.font = font;
        [titleButton setTitle:title forState:UIControlStateNormal];
        [self.scrollView addSubview:titleButton];
        [newTitleButtons addObject:titleButton];
    
        xOffset = xOffset + titleSize.width + self.spacing;
    }
    
    self.scrollView.contentSize = CGSizeMake(xOffset, CGRectGetHeight(self.scrollView.bounds));
    
    self.titleButtons = newTitleButtons;
    _titles = titles;
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
//    UIButton *button = self.titleButtons[currentIndex];
//    [self.segmentedControl setSelectedSegmentIndex:self.currentIndex];
}

- (void)pressedTitleButton:(id)sender
{
    UIButton *button = sender;
    self.currentIndex = button.tag;
}

@end
