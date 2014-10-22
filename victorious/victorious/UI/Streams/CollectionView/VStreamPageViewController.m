//
//  VStreamPageViewController.m
//  victorious
//
//  Created by Will Long on 10/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamPageViewController.h"

#import "VConstants.h"

#import "VSequenceActionController.h"
#import "VStreamCollectionViewController.h"
#import "VAuthorizationViewControllerFactory.h"

#import "VObjectManager+Login.h"

#import "VNode.h"
#import "VSequence+Fetcher.h"
#import "VStream+Fetcher.h"
#import "UIViewController+VNavMenu.h"

#import "VStreamCollectionCell.h"

#import "VSettingManager.h"
#import "VThemeManager.h"

@interface VStreamPageViewController () <VSequenceActionsDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate, VNavigationHeaderDelegate>

@property (nonatomic, strong) NSArray *allStreams;
@property (nonatomic, strong) VStream *defaultStream;

@property (nonatomic, strong) NSMutableArray *streamVCs;

@property (nonatomic, strong) VSequenceActionController *sequenceActionController;

@end

@implementation VStreamPageViewController

+ (instancetype)homeStream
{
    VStream *recentStream = [VStream streamForCategories: [VUGCCategories() arrayByAddingObjectsFromArray:VOwnerCategories()]];
    VStream *hotStream = [VStream hotSteamForSteamName:@"home"];
    VStream *followingStream = [VStream followerStreamForStreamName:@"home" user:nil];
    
    VStreamPageViewController *streamPager = [self streamPageVCForDefaultStream:recentStream
                                                                  andAllStreams: @[hotStream, recentStream, followingStream]
                                                                          title:NSLocalizedString(@"Home", nil)];
    streamPager.shouldDisplayMarquee = YES;
    [streamPager addCreateSequenceButton];

    return streamPager;
}

+ (instancetype)communityStream
{
    VStream *recentStream = [VStream streamForCategories: VUGCCategories()];
    VStream *hotStream = [VStream hotSteamForSteamName:@"ugc"];
    
    VStreamPageViewController *streamPager = [self streamPageVCForDefaultStream:recentStream
                                                                  andAllStreams:@[hotStream, recentStream]
                                                                          title:NSLocalizedString(@"Community", nil)];
    streamPager.navHeaderView.showHeaderLogoImage = YES;
    [streamPager addCreateSequenceButton];
    
    return streamPager;
}

+ (instancetype)ownerStream
{
    VStream *recentStream = [VStream streamForCategories: VOwnerCategories()];
    VStream *hotStream = [VStream hotSteamForSteamName:@"owner"];
    
    VStreamPageViewController *ownerStream = [self streamPageVCForDefaultStream:recentStream
                                                                  andAllStreams:@[hotStream, recentStream]
                                                                          title:NSLocalizedString(@"Owner", nil)];
    return ownerStream;
}

+ (instancetype)streamPageVCForDefaultStream:(VStream *)stream andAllStreams:(NSArray *)allStreams title:(NSString *)title
{
    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VStreamPageViewController *streamPager =  (VStreamPageViewController *)[currentViewController.storyboard instantiateViewControllerWithIdentifier: @"kStreamPager"];
    streamPager.title = title;
    streamPager.defaultStream = stream;
    streamPager.allStreams = allStreams;
    
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    for (VStream *stream in allStreams)
    {
        [titles addObject:stream.name];
    }
    [streamPager addNewNavHeaderWithTitles:titles];
    NSInteger selectedStream = [allStreams indexOfObject:streamPager.defaultStream];
    streamPager.navHeaderView.navSelector.currentIndex = selectedStream;
    streamPager.navHeaderView.delegate = streamPager;
    
    return streamPager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;
    self.streamVCs = [[NSMutableArray alloc] init];
    self.sequenceActionController = [[VSequenceActionController alloc] init];
    
    self.allStreams = self.allStreams;
    
    self.view.backgroundColor = [[VThemeManager sharedThemeManager] preferredBackgroundColor];
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
    
    [self deleteStreamVCs];
    
    for (VStream *stream in allStreams)
    {
        VStreamCollectionViewController *streamVC = [VStreamCollectionViewController streamViewControllerForStream:stream];
        streamVC.delegate = self;
        UIEdgeInsets insets = streamVC.collectionView.contentInset;
        insets.top = CGRectGetHeight(self.navHeaderView.frame);
        streamVC.contentInset = insets;
        
        if (stream == self.defaultStream)
        {
            streamVC.shouldDisplayMarquee = self.shouldDisplayMarquee;
        }
        
        [self.streamVCs addObject:streamVC];
    }
    VStreamCollectionViewController *defaultStreamVC = self.streamVCs[[self.allStreams indexOfObject:self.defaultStream]];
    NSArray *initialVC = @[defaultStreamVC];
    [self setViewControllers:initialVC direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)setShouldDisplayMarquee:(BOOL)shouldDisplayMarquee
{
    _shouldDisplayMarquee = shouldDisplayMarquee;
    
    VStreamCollectionViewController *defaultStreamVC = self.streamVCs[[self.allStreams indexOfObject:self.defaultStream]];
    defaultStreamVC.shouldDisplayMarquee = shouldDisplayMarquee;
}

- (void)deleteStreamVCs
{
    for (UIViewController *viewController in self.streamVCs)
    {
        [viewController willMoveToParentViewController:nil];
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
    }
    [self.streamVCs removeAllObjects];
}

#pragma mark - VSequenceActionsDelegate

- (void)willCommentOnSequence:(VSequence *)sequenceObject fromView:(UIView *)streamCollectionCell
{
    [self.sequenceActionController showCommentsFromViewController:self sequence:sequenceObject];
}

- (void)selectedUserOnSequence:(VSequence *)sequence fromView:(UIView *)streamCollectionCell
{
    [self.sequenceActionController showPosterProfileFromViewController:self sequence:sequence];
}

- (void)willRemixSequence:(VSequence *)sequence fromView:(UIView *)view
{
    if ([sequence isVideo])
    {
        [self.sequenceActionController videoRemixActionFromViewController:self asset:[sequence firstNode].assets.firstObject node:[sequence firstNode] sequence:sequence];
    }
    else
    {
        [self.sequenceActionController imageRemixActionFromViewController:self previewImage:nil sequence: sequence];
    }
}

- (void)willShareSequence:(VSequence *)sequence fromView:(UIView *)view
{
    [self.sequenceActionController shareFromViewController:self sequence:sequence node:[sequence firstNode]];
}

- (BOOL)willRepostSequence:(VSequence *)sequence fromView:(UIView *)view
{
    return [self.sequenceActionController repostActionFromViewController:self node:[sequence firstNode]];
}

- (void)willFlagSequence:(VSequence *)sequence fromView:(UIView *)view
{
    [self.sequenceActionController flagSheetFromViewController:self sequence:sequence];
}

#pragma mark - VNavigationHeaderDelegate

- (BOOL)navSelector:(UIView<VNavigationSelectorProtocol> *)navSelector changedToIndex:(NSInteger)index
{
    if (self.allStreams.count <= (NSUInteger)index)
    {
        return NO;
    }
    
    NSInteger lastIndex = self.navHeaderView.lastSelectedControl;
    
    VStream *stream = self.allStreams[index];
    if ([stream.apiPath rangeOfString:VStreamFollowerStreamPath].location != NSNotFound
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
    }
            return YES;
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
//    NSUInteger index = [self.streamVCs indexOfObject:[pendingViewControllers lastObject]];
//    self.navHeaderView.navSelector.currentIndex = index;
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
