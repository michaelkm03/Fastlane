//
//  VStreamPageViewController.m
//  victorious
//
//  Created by Will Long on 10/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamPageViewController.h"

#import "VConstants.h"

#import "VStreamCollectionViewController.h"
#import "VAuthorizationViewControllerFactory.h"

#import "VObjectManager+Login.h"

#import "VStream+Fetcher.h"
#import "UIViewController+VNavMenu.h"

#import "VSettingManager.h"

@interface VStreamPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate, VNavigationHeaderDelegate>

@property (nonatomic, strong) NSArray *allStreams;
@property (nonatomic, strong) VStream *defaultStream;

@property (nonatomic, strong) NSMutableArray *streamVCs;

@end

@implementation VStreamPageViewController

+ (instancetype)homeStream
{
    VStream *recentStream = [VStream streamForCategories: [VUGCCategories() arrayByAddingObjectsFromArray:VOwnerCategories()]];
    VStream *hotStream = [VStream hotSteamForSteamName:@"home"];
    VStream *followingStream = [VStream followerStreamForStreamName:@"home" user:nil];
    
    
    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VStreamPageViewController *homeStream = (VStreamPageViewController *)[currentViewController.storyboard instantiateViewControllerWithIdentifier: @"kStreamPager"];
    homeStream.defaultStream = recentStream;
    homeStream.allStreams = @[hotStream, recentStream, followingStream];
    homeStream.title = NSLocalizedString(@"Home", nil);
    homeStream.shouldDisplayMarquee = YES;
    
    return homeStream;
}

+ (instancetype)communityStream
{
    VStream *recentStream = [VStream streamForCategories: VUGCCategories()];
    VStream *hotStream = [VStream hotSteamForSteamName:@"ugc"];
    
    
    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VStreamPageViewController *communityStream =  (VStreamPageViewController *)[currentViewController.storyboard instantiateViewControllerWithIdentifier: @"kStreamPager"];
    communityStream.defaultStream = recentStream;
    communityStream.allStreams = @[hotStream, recentStream];
    communityStream.title = NSLocalizedString(@"Community", nil);
    communityStream.navHeaderView.showHeaderLogoImage = YES;
    
    return communityStream;
}

+ (instancetype)ownerStream
{
    VStream *recentStream = [VStream streamForCategories: VOwnerCategories()];
    VStream *hotStream = [VStream hotSteamForSteamName:@"owner"];
    
    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VStreamPageViewController *ownerStream = (VStreamPageViewController *)[currentViewController.storyboard instantiateViewControllerWithIdentifier: @"kStreamPager"];
    ownerStream.defaultStream = recentStream;
    ownerStream.allStreams = @[hotStream, recentStream];
    
    ownerStream.title = NSLocalizedString(@"Owner", nil);
    
    return ownerStream;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.dataSource = self;
    self.delegate = self;
    self.streamVCs = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.allStreams = self.allStreams;
    
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    for (VStream *stream in self.allStreams)
    {
        [titles addObject:stream.name];
    }
    [self addNewNavHeaderWithTitles:titles];
    self.navHeaderView.delegate = self;
    NSInteger selectedStream = [self.allStreams indexOfObject:self.defaultStream];
    self.navHeaderView.navSelector.currentIndex = selectedStream;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (BOOL)prefersStatusBarHidden
{
    return !CGRectContainsRect(self.view.frame, self.navHeaderView.frame);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return ![[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled] ? UIStatusBarStyleLightContent
    : UIStatusBarStyleDefault;
}

- (void)setAllStreams:(NSArray *)allStreams
{
    _allStreams = allStreams;
    
    if (!self.isViewLoaded)
    {
        return;
    }
    
    [self.streamVCs removeAllObjects];
    
    for (VStream *stream in allStreams)
    {
        VStreamCollectionViewController *streamVC = [VStreamCollectionViewController streamViewControllerForStream:stream];
        streamVC.delegate = self;
        UIEdgeInsets insets = streamVC.collectionView.contentInset;
        insets.top = CGRectGetHeight(self.navHeaderView.frame);
        streamVC.collectionView.contentInset = insets;
        streamVC.collectionView.contentOffset = CGPointMake(streamVC.collectionView.contentOffset.x, insets.top);
        
        if (stream == self.defaultStream)
        {
            streamVC.shouldDisplayMarquee = self.shouldDisplayMarquee;
        }
        
        [self.streamVCs addObject:streamVC];
    }
    
    NSArray *initialVC = @[self.streamVCs[[self.allStreams indexOfObject:self.defaultStream]]];
    [self setViewControllers:initialVC direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

#pragma mark - VNavigationHeaderDelegate

- (BOOL)navHeaderView:(VNavigationHeaderView *)navHeaderView changedToIndex:(NSInteger)index
{
    if (self.allStreams.count <= (NSUInteger)index)
    {
        return NO;
    }
    
    NSInteger lastIndex = self.navHeaderView.lastSelectedControl;
    
    VStream *stream = self.allStreams[index];
    if ([stream.apiPath rangeOfString:VStreamFollowerStreamPath].location == NSNotFound
        && ![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return NO;
    }
    else
    {
        VStreamCollectionViewController *streamCollection = self.streamVCs[index];
        UIPageViewControllerNavigationDirection direction = lastIndex < index ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
        [self setViewControllers:@[streamCollection]
                       direction:direction
                        animated:YES
                      completion:nil];
        
        return YES;
    }
}

#pragma mark - UIScrollViewdelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    
    if (translation.y < 0 && scrollView.contentOffset.y > CGRectGetHeight(self.navHeaderView.frame))
    {
        [UIView animateWithDuration:.2f animations:^
         {
             [self hideHeader];
         }];
    }
    else if (translation.y > 0)
    {
        [UIView animateWithDuration:.2f animations:^
         {
             [self showHeader];
         }];
    }
}

#pragma mark - UIPageViewDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    NSUInteger index = [self.streamVCs indexOfObject:[self.viewControllers lastObject]];
    self.navHeaderView.navSelector.currentIndex = index;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    NSUInteger index = [self.streamVCs indexOfObject:[pendingViewControllers lastObject]];
    self.navHeaderView.navSelector.currentIndex = index;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    NSAssert(pageViewController == self, @"");
    
    NSUInteger index = [self.streamVCs indexOfObject:viewController];
    
    if (index == self.streamVCs.count - 1)
    {
        return nil;
    }
    else
    {
        return self.streamVCs[index+1];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSAssert(pageViewController == self, @"");
    
    NSUInteger index = [self.streamVCs indexOfObject:viewController];
    
    if (index == 0)
    {
        return nil;
    }
    else
    {
        return self.streamVCs[index-1];
    }
}

@end
