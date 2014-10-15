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

@interface VSwipeNavSelector() <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *titleButtons;
@property (nonatomic) CGFloat spacing;

@property (nonatomic) BOOL isAnimatingScrollview;

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
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
//    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;

    [self addSubview:self.scrollView];
    
    self.spacing = 55;
    
    self.indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, kVIndicatorViewHeight)];
    self.indicatorView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryLinkColor];
    self.widthConstraint = [NSLayoutConstraint constraintWithItem:self.indicatorView
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:10];
    NSLayoutConstraint *centerConstraint = [NSLayoutConstraint constraintWithItem:self.indicatorView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1.0
                                                                         constant:0];
    [self addSubview:self.indicatorView];
    [self addConstraints:@[centerConstraint, self.widthConstraint]];
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
        [titleButton addTarget:self action:@selector(pressedTitleButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.scrollView addSubview:titleButton];
        [newTitleButtons addObject:titleButton];
    
        xOffset = xOffset + titleSize.width + self.spacing;
    }
    xOffset -= self.spacing;//Remove the extra spacing from the last loop.
    
    self.scrollView.contentSize = CGSizeMake(xOffset, CGRectGetHeight(self.scrollView.bounds));

    UIButton *leftButton = [newTitleButtons firstObject];
    CGFloat leftInset = (CGRectGetWidth(self.bounds) - CGRectGetWidth(leftButton.frame)) / 2;
    UIButton *rightButton = [newTitleButtons lastObject];
    CGFloat rightInset = (CGRectGetWidth(self.bounds) - CGRectGetWidth(rightButton.frame)) / 2;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, leftInset, 0, rightInset);
    
    self.titleButtons = newTitleButtons;
    _titles = titles;
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    if (_currentIndex == currentIndex || currentIndex > (NSInteger)self.titleButtons.count) //Prevent dem infinite loops
    {
        return;
    }
    
    _currentIndex = currentIndex;
    UIButton *button = self.titleButtons[currentIndex];
    CGPoint contentOffset = CGPointMake(CGRectGetMidX(button.frame) - CGRectGetWidth(self.scrollView.frame) / 2,
                                         self.scrollView.contentOffset.y);
    self.isAnimatingScrollview = YES;
    [self.scrollView setContentOffset:contentOffset animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(navSelector:selectedIndex:)])
    {
        [self.delegate navSelector:self selectedIndex:self.currentIndex];
    }
}

- (void)pressedTitleButton:(id)sender
{
    UIButton *button = sender;
    self.currentIndex = button.tag;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isAnimatingScrollview)//if we're animating the scrollview we're already in the middle of a page animation
    {
        return;
    }
    
    UIButton *closestButton;
    CGFloat xOffset = scrollView.contentOffset.x + CGRectGetWidth(self.scrollView.frame) / 2;
    for (UIButton *button in self.titleButtons)
    {
        CGFloat newButtonDifference = ABS(xOffset - CGRectGetMinX(button.frame));
        CGFloat oldButtonDifference = ABS(xOffset - CGRectGetMinX(closestButton.frame));
        if (newButtonDifference <= oldButtonDifference)
        {
            closestButton = button;
        }
    }
    self.currentIndex = [self.titleButtons indexOfObject:closestButton];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.isAnimatingScrollview = NO;
}

@end
