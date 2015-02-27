//
//  VMarqueeTabIndicatorView.m
//  victorious
//
//  Created by Will Long on 9/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMarqueeTabIndicatorView.h"

@interface VMarqueeTabIndicatorView ()

@property (nonatomic, strong) NSArray *tabImageViews;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation VMarqueeTabIndicatorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.clipsToBounds = YES;
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:self.scrollView];
    }
    return self;
}

- (void)setCurrentlySelectedTab:(NSUInteger)currentlySelectedTab
{
    if (_currentlySelectedTab == currentlySelectedTab)
    {
        return;
    }
    _currentlySelectedTab = currentlySelectedTab;
    
    [self.tabImageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if (idx == currentlySelectedTab)
         {
             UIImageView *imageView = obj;
             imageView.tintColor = self.selectedColor;
             if (imageView.frame.origin.x < self.scrollView.contentOffset.x)
             {
                 [self.scrollView setContentOffset:CGPointMake(imageView.frame.origin.x, self.scrollView.contentOffset.y) animated:YES];
             }
             else if (CGRectGetMaxX(imageView.frame) > self.scrollView.contentOffset.x + CGRectGetWidth(self.scrollView.bounds))
             {
                 CGFloat xOffset = CGRectGetMaxX(imageView.frame) - CGRectGetWidth(self.scrollView.bounds);
                 [self.scrollView setContentOffset:CGPointMake(xOffset, self.scrollView.contentOffset.y) animated:YES];
             }
         }
         else
         {
             ((UIImageView *)obj).tintColor = self.deselectedColor;
         }
     }];
}

- (void)setSpacingBetweenTabs:(CGFloat)spacingBetweenTabs
{
    if (_spacingBetweenTabs == spacingBetweenTabs)
    {
        return;
    }
    _spacingBetweenTabs = spacingBetweenTabs;
    [self updateUI];
}

- (void)setTabImage:(UIImage *)tabImage
{
    _tabImage = [tabImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self updateUI];
}

- (void)setNumberOfTabs:(NSUInteger)numberOfTabs
{
    if (_numberOfTabs == numberOfTabs)
    {
        return;
    }
    _numberOfTabs = numberOfTabs;
    [self updateUI];
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    if ([_selectedColor isEqual:selectedColor])
    {
        return;
    }
    _selectedColor = selectedColor;
    [self updateUI];
}

- (void)setDeselectedColor:(UIColor *)deselectedColor
{
    if ([_deselectedColor isEqual:deselectedColor])
    {
        return;
    }
    _deselectedColor = deselectedColor;
    [self updateUI];
}

- (void)updateUI
{
    for (UIImageView *imageView in self.tabImageViews)
    {
        [imageView removeFromSuperview];
    }
    
    //Return to the first tab if the current tab is out of bounds
    if (self.currentlySelectedTab >= self.numberOfTabs)
    {
        _currentlySelectedTab = 0;
    }
    
    NSMutableArray *imageViews = [[NSMutableArray alloc] initWithCapacity:self.numberOfTabs];
    CGFloat imageWidth = self.tabImage.size.width;
    CGFloat xCenter = 0.0f;
    for (NSUInteger i = 0; i < self.numberOfTabs; i++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.tabImage];
        xCenter = (i * (imageWidth + self.spacingBetweenTabs)) + (imageWidth / 2.0f);
        imageView.center = CGPointMake(xCenter, CGRectGetHeight(self.bounds) / 2.0f);
        
        imageView.tintColor = i == self.currentlySelectedTab ? self.selectedColor : self.deselectedColor;
        
        [self.scrollView addSubview:imageView];
        imageViews[i] = imageView;
    }
    CGFloat totalWidth = xCenter + imageWidth/2.0f;
    self.tabImageViews = imageViews;
    
    if (totalWidth < CGRectGetWidth(self.bounds))
    {
        CGFloat xOffset = (CGRectGetWidth(self.bounds) - totalWidth) / 2.0f;
        self.scrollView.contentInset = UIEdgeInsetsMake(0.0f, xOffset, 0.0f, 0.0f);
    }
    else
    {
        self.scrollView.contentInset = UIEdgeInsetsZero;
    }
}

@end
