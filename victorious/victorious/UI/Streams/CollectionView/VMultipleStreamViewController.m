//
//  VMultipleStreamViewController.m
//  victorious
//
//  Created by Will Long on 10/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMultipleStreamViewController.h"

#import "UIViewController+VNavMenu.h"
#import "VNavigationSelectorProtocol.h"

#import "VStream+Fetcher.h"
#import "VSequence+Fetcher.h"
#import "VNode.h"

#import "VStreamCollectionViewController.h"

#import "VSequenceActionController.h"
#import "VSequenceActionsDelegate.h"

#import "VConstants.h"

#import "VSettingManager.h"
#import "VThemeManager.h"
#import "VObjectManager+Login.h"
#import "VAuthorizationViewControllerFactory.h"
#import "UIStoryboard+VMainStoryboard.h"

@interface VMultipleStreamViewController () <VSequenceActionsDelegate, UIScrollViewDelegate, VNavigationHeaderDelegate, VUploadProgressViewControllerDelegate>

@property (nonatomic, strong) NSArray *allStreams;
@property (nonatomic, strong) VStream *defaultStream;

@property (nonatomic, strong) NSMutableArray *streamVCs;

@property (nonatomic, strong) VSequenceActionController *sequenceActionController;

@end

static NSString * const kVMultiStreamStoryboardID = @"kMultiStream";

@implementation VMultipleStreamViewController

+ (instancetype)homeStream
{
    VStream *recentStream = [VStream streamForCategories: [VUGCCategories() arrayByAddingObjectsFromArray:VOwnerCategories()]];
    VStream *hotStream = [VStream hotSteamForSteamName:@"home"];
    VStream *followingStream = [VStream followerStreamForStreamName:@"home" user:nil];
    
    VMultipleStreamViewController *streamPager = [self multiStreamVCForDefaultStream:recentStream
                                                                  andAllStreams: @[hotStream, recentStream, followingStream]
                                                                          title:NSLocalizedString(@"Home", nil)];
    streamPager.shouldDisplayMarquee = YES;
    [streamPager v_addCreateSequenceButton];
    [streamPager v_addUploadProgressView];
    streamPager.uploadProgressViewController.delegate = streamPager;
    
    return streamPager;
}

+ (instancetype)communityStream
{
    VStream *recentStream = [VStream streamForCategories: VUGCCategories()];
    VStream *hotStream = [VStream hotSteamForSteamName:@"ugc"];
    
    VMultipleStreamViewController *streamPager = [self multiStreamVCForDefaultStream:recentStream
                                                                  andAllStreams:@[hotStream, recentStream]
                                                                          title:NSLocalizedString(@"Community", nil)];
    streamPager.navHeaderView.showHeaderLogoImage = YES;
    [streamPager v_addCreateSequenceButton];
    
    return streamPager;
}

+ (instancetype)ownerStream
{
    VStream *recentStream = [VStream streamForCategories: VOwnerCategories()];
    VStream *hotStream = [VStream hotSteamForSteamName:@"owner"];
    
    VMultipleStreamViewController *ownerStream = [self multiStreamVCForDefaultStream:recentStream
                                                                  andAllStreams:@[hotStream, recentStream]
                                                                          title:NSLocalizedString(@"Owner", nil)];
    return ownerStream;
}

+ (instancetype)multiStreamVCForDefaultStream:(VStream *)stream andAllStreams:(NSArray *)allStreams title:(NSString *)title
{
    VMultipleStreamViewController *streamPager = (VMultipleStreamViewController *)[[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier: kVMultiStreamStoryboardID];
    streamPager.title = title;
    streamPager.defaultStream = stream;
    streamPager.allStreams = allStreams;
    
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    for (VStream *stream in allStreams)
    {
        [titles addObject:stream.name];
    }
    [streamPager v_addNewNavHeaderWithTitles:titles];
    NSInteger selectedStream = [allStreams indexOfObject:streamPager.defaultStream];
    streamPager.navHeaderView.navSelector.currentIndex = selectedStream;
    streamPager.navHeaderView.delegate = streamPager;
    
    return streamPager;
}

#pragma mark - View Stuff

- (void)dealloc
{
    [self deleteStreamVCs];
    self.navHeaderView.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
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

- (BOOL)shouldAutorotate
{
    return NO;
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
    
    CGFloat xOffset = CGRectGetMinX(self.scrollView.frame);
    for (VStream *stream in allStreams)
    {
        VStreamCollectionViewController *streamVC = [VStreamCollectionViewController streamViewControllerForStream:stream];
        streamVC.delegate = self;
        streamVC.actionDelegate = self;
        UIEdgeInsets insets = streamVC.collectionView.contentInset;
        insets.top = CGRectGetHeight(self.navHeaderView.frame);
        streamVC.contentInset = insets;
        
        streamVC.view.frame = CGRectMake(xOffset, CGRectGetMinY(self.scrollView.frame),
                                         CGRectGetWidth(streamVC.view.bounds), CGRectGetHeight(streamVC.view.bounds));
        xOffset += CGRectGetWidth(streamVC.view.bounds);
        
        if (stream == self.defaultStream)
        {
            streamVC.shouldDisplayMarquee = self.shouldDisplayMarquee;
        }
        
        [streamVC willMoveToParentViewController:self];
        [self.scrollView addSubview:streamVC.view];
        [self addChildViewController:streamVC];
        [self.streamVCs addObject:streamVC];
    }
    self.scrollView.contentSize = CGSizeMake(xOffset, CGRectGetHeight(self.scrollView.bounds));
    
    
    VStreamCollectionViewController *streamCollection = self.streamVCs[[self.allStreams indexOfObject:self.defaultStream]];
    [self.scrollView setContentOffset:CGPointMake(CGRectGetMinX(streamCollection.view.frame), self.scrollView.contentOffset.y) animated:YES];
}

- (void)setShouldDisplayMarquee:(BOOL)shouldDisplayMarquee
{
    _shouldDisplayMarquee = shouldDisplayMarquee;
    
    VStreamCollectionViewController *defaultStreamVC = self.streamVCs[[self.allStreams indexOfObject:self.defaultStream]];
    defaultStreamVC.shouldDisplayMarquee = shouldDisplayMarquee;
}

- (void)deleteStreamVCs
{
    for (VStreamCollectionViewController *viewController in self.streamVCs)
    {
        viewController.delegate = nil;
        viewController.actionDelegate = nil;
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
//        [self.sequenceActionController videoRemixActionFromViewController:self asset:[sequence firstNode].assets.firstObject node:[sequence firstNode] sequence:sequence withDependencyManager:self.];
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
    BOOL shouldChange = YES;
    NSInteger finalIndex = index;
    
    if (self.allStreams.count <= (NSUInteger)index)
    {
        finalIndex = self.navHeaderView.navSelector.lastIndex;
        shouldChange = NO;
    }

    VStream *stream = self.allStreams[index];
    if ([stream.apiPath rangeOfString:VStreamFollowerStreamPath].location != NSNotFound
        && ![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        finalIndex = self.navHeaderView.navSelector.lastIndex;
        shouldChange = NO;
    }
    
    VStreamCollectionViewController *streamCollection = self.streamVCs[finalIndex];
    [self.scrollView setContentOffset:CGPointMake(CGRectGetMinX(streamCollection.view.frame), self.scrollView.contentOffset.y) animated:YES];
    
    return shouldChange;
}

#pragma mark - VNewContentViewControllerDelegate

- (void)newContentViewControllerDidClose:(VNewContentViewController *)contentViewController
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)newContentViewControllerDidDeleteContent:(VNewContentViewController *)contentViewController
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - VUploadProgressViewControllerDelegate methods

- (void)uploadProgressViewController:(VUploadProgressViewController *)upvc isNowDisplayingThisManyUploads:(NSInteger)uploadCount
{
    if (uploadCount)
    {
        [self v_showUploads];
    }
    else
    {
        [self v_hideUploads];
    }
}

#pragma mark - UIScrollViewdelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = (NSInteger)(scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame));
    self.navHeaderView.navSelector.currentIndex = index;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    
    if (translation.y < 0 && scrollView.contentOffset.y > CGRectGetHeight(self.navHeaderView.frame))
    {
        [UIView animateWithDuration:.2f animations:^
         {
             [self v_hideHeader];
         }];
    }
    else if (translation.y > 0)
    {
        [UIView animateWithDuration:.2f animations:^
         {
             [self v_showHeader];
         }];
    }
}

@end
