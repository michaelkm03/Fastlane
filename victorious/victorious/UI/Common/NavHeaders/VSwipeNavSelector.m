//
//  VSwipeNavSelector.m
//  victorious
//
//  Created by Will Long on 10/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSwipeNavSelector.h"

#import "VThemeManager.h"

#import "VNavigationHeaderView.h"

static CGFloat const kVIndicatorViewHeight = 3;

@interface VSwipeNavSelector() <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *indicatorView;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *titleButtons;
@property (nonatomic) CGFloat spacing;

@end

@implementation VSwipeNavSelector

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
    self.layer.borderColor = [[[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryLinkColor] colorWithAlphaComponent:.1].CGColor;
    self.layer.borderWidth = 1;

    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self removeConstraints:self.constraints];//Need to do this because the autoresizing constraints are added before we init >:/
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;

    [self addSubview:self.scrollView];
    
    self.spacing = 55;
    
    self.indicatorView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.frame), 0, 0, kVIndicatorViewHeight)];
    self.indicatorView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryLinkColor];
    [self addSubview:self.indicatorView];
}

- (void)setTitles:(NSArray *)titles
{
    for (UIButton *button in self.titleButtons)
    {
        [button removeFromSuperview];
    }
    
    UIFont *font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
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
    if (currentIndex > (NSInteger)self.titleButtons.count) //Prevent dem infinite loops
    {
        return;
    }
    
    self.lastIndex = _currentIndex;
    _currentIndex = currentIndex;
    
    BOOL shouldChange = YES;
    if ([self.delegate respondsToSelector:@selector(navSelector:changedToIndex:)])
    {
        shouldChange = [self.delegate navSelector:self changedToIndex:currentIndex];
    }
    
    if (!shouldChange)
    {
        _currentIndex = self.lastIndex;
        [self scrollToButtonAtIndex:self.lastIndex];
        return;
    }
    
    [self scrollToButtonAtIndex:currentIndex];
}

- (void)scrollToButtonAtIndex:(NSInteger)index
{
    UIButton *button = self.titleButtons[index];
    CGPoint contentOffset = CGPointMake(CGRectGetMidX(button.frame) - CGRectGetWidth(self.scrollView.frame) / 2,
                                        self.scrollView.contentOffset.y);
    self.scrollView.scrollEnabled = NO;
    [self.scrollView setContentOffset:contentOffset animated:YES];
    
    [UIView animateWithDuration:.2f
                     animations:
     ^{
         self.indicatorView.frame = CGRectMake(CGRectGetMidX(self.frame) - CGRectGetWidth(button.frame)/2,
                                               CGRectGetMinY(self.indicatorView.frame),
                                               CGRectGetWidth(button.frame),
                                               CGRectGetHeight(self.indicatorView.frame));
     }];
}

- (void)pressedTitleButton:(id)sender
{
    UIButton *button = sender;
    self.currentIndex = button.tag;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.scrollView.scrollEnabled)
    {
        return;
    }
    
    UIButton *closestButton = [self closestButtonForOffset:scrollView.contentOffset];
    if ((unsigned)self.currentIndex != [self.titleButtons indexOfObject:closestButton])
    {
        self.currentIndex = [self.titleButtons indexOfObject:closestButton];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        UIButton *closestButton = [self closestButtonForOffset:scrollView.contentOffset];
        self.currentIndex = [self.titleButtons indexOfObject:closestButton];
    }
}

- (UIButton *)closestButtonForOffset:(CGPoint)offset
{
    UIButton *closestButton;
    CGFloat xOffset = offset.x + CGRectGetWidth(self.scrollView.frame) / 2;
    for (UIButton *button in self.titleButtons)
    {
        CGFloat newButtonDifference = ABS(xOffset - CGRectGetMinX(button.frame));
        CGFloat oldButtonDifference = ABS(xOffset - CGRectGetMinX(closestButton.frame));
        if (newButtonDifference <= oldButtonDifference)
        {
            closestButton = button;
        }
    }
    return closestButton;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    UIButton *closestButton = [self closestButtonForOffset:scrollView.contentOffset];
    self.currentIndex = [self.titleButtons indexOfObject:closestButton];
    self.scrollView.scrollEnabled = YES;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.scrollView.scrollEnabled = YES;
}

@end
