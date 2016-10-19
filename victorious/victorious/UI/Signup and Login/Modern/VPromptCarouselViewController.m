//
//  VPromptCarouselViewController.m
//  victorious
//
//  Created by Michael Sena on 5/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPromptCarouselViewController.h"

// Views + Helpers
#import "VLinearGradientView.h"
#import "VPromptCollectionViewCell.h"
#import "VTimerManager.h"

// Dependencies
#import "VDependencyManager.h"

static NSString * const kPromptsKey = @"prompts";
static NSString * const kPromptDurationKey = @"promptDuration";

@interface VPromptCarouselViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) NSArray *prompts;

@property (nonatomic, strong) VTimerManager *timerManager;

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property (nonatomic, weak) IBOutlet VLinearGradientView *gradientMaskView;

@end

@interface VDependencyManager (accessors)

@property(nonatomic, nullable, readonly)UIColor *unselectedPageColor;
@property(nonatomic, nullable, readonly)UIColor *selectedPageColor;

@end

@implementation VDependencyManager (accessors)

- (UIColor *)unselectedPageColor
{
    return [self colorForKey:@"color.accent.secondary"];
}

- (UIColor *)selectedPageColor
{
    return [self colorForKey:@"color.accent"];
}

@end

@implementation VPromptCarouselViewController

- (void)dealloc
{
    _collectionView.delegate = nil;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    _prompts = [dependencyManager arrayForKey:kPromptsKey];
    
    if (_prompts == nil || _prompts.count == 0)
    {
        self.view.hidden = YES;
        self.collectionView.dataSource = nil;
        return;
    }
    
    [self.collectionView reloadData];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_prompts.count == 1)
    {
        self.pageControl.hidden = YES;
    }
    
    self.collectionView.alpha = 0.0f;
    [self.flowLayout invalidateLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupTimer];
    
    [self.flowLayout invalidateLayout];
    [UIView animateWithDuration:0.5f
                          delay:0.5f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.collectionView.alpha = 1.0f;
     }
                     completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pageControl.pageIndicatorTintColor = self.dependencyManager.unselectedPageColor;
    self.pageControl.currentPageIndicatorTintColor = self.dependencyManager.selectedPageColor;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.gradientMaskView setColors:@[[UIColor clearColor], [UIColor blackColor], [UIColor blackColor], [UIColor clearColor]]];
    [self.gradientMaskView setLocations:@[@(0.0f), @(0.1f), @(0.9f), @(1.0f)]];
    self.gradientMaskView.startPoint = CGPointMake(0, 0.5f);
    self.gradientMaskView.endPoint = CGPointMake(1, 0.5f);
    self.view.maskView = self.gradientMaskView;
}

#pragma mark - Target/Action

- (IBAction)selectedPage:(UIPageControl *)sender
{
    [self setupTimer];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:sender.currentPage inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    self.pageControl.numberOfPages = self.prompts.count;
    return self.prompts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VPromptCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VPromptCollectionViewCell suggestedReuseIdentifier]
                                                                                forIndexPath:indexPath];
    NSString *promptAtIndex = self.prompts[indexPath.row];
    NSDictionary *promptAttributes = @{
                                       NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey],
                                       NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerHeading1FontKey],
                                       };
    NSAttributedString *attributedPrompt = [[NSAttributedString alloc] initWithString:promptAtIndex
                                                                           attributes:promptAttributes];
    [cell setAttributedTitle:attributedPrompt];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [VPromptCollectionViewCell desiredSizeWithCollectionViewBounds:collectionView.bounds];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = [self.collectionView indexPathForItemAtPoint:CGPointMake(CGRectGetMidX(self.collectionView.bounds), CGRectGetMidY(self.collectionView.bounds))].row;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.timerManager invalidate];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [self setupTimer];
}

#pragma mark - Private Methods

- (void)nextItem
{
    BOOL atLeastOneItem = [self.collectionView numberOfItemsInSection:0] > 0;
    if (!atLeastOneItem)
    {
        [self.timerManager invalidate];
        return;
    }
    
    if (self.collectionView.isDragging || self.collectionView.isTracking)
    {
        [self.timerManager invalidate];
        return;
    }

    NSIndexPath *currentIndexPath = [self.collectionView indexPathForItemAtPoint:CGPointMake(CGRectGetMidX(self.collectionView.bounds),
                                                                                             CGRectGetMidY(self.collectionView.bounds))];
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:currentIndexPath.item + 1 inSection:currentIndexPath.section];
    if ((nextIndexPath.item) < [self.collectionView numberOfItemsInSection:currentIndexPath.section])
    {
        [self.collectionView scrollToItemAtIndexPath:nextIndexPath
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:YES];
    }
    else
    {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:YES];
    }
}

- (void)setupTimer
{
    [self.timerManager invalidate];
    NSNumber *promptDuration = [self.dependencyManager numberForKey:kPromptDurationKey];
    NSTimeInterval promptInterval = [promptDuration doubleValue] / 1000;
    if (promptInterval == 0)
    {
        return;
    }
    self.timerManager = [VTimerManager scheduledTimerManagerWithTimeInterval:promptInterval
                                                                      target:self
                                                                    selector:@selector(nextItem)
                                                                    userInfo:nil
                                                                     repeats:YES];
}

@end
