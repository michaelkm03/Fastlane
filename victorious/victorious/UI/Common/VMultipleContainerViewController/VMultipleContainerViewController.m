//
//  VMultipleContainerViewController.m
//  victorious
//
//  Created by Josh Hinman on 12/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIViewController+VLayoutInsets.h"
#import "VDependencyManager+VScaffoldViewController.h"
#import "VDependencyManager+VNavigationItem.h"
#import "VMultipleContainer.h"
#import "VMultipleContainerViewController.h"
#import "VNavigationController.h"
#import "VSelectorViewBase.h"
#import "VStreamCollectionViewController.h"
#import "VAuthorizationContext.h"
#import "VNavigationDestination.h"
#import "VProvidesNavigationMenuItemBadge.h"
#import "UIView+AutoLayout.h"

@interface VMultipleContainerViewController () <UICollectionViewDataSource, UICollectionViewDelegate, VSelectorViewDelegate, VMultipleContainerChildDelegate, VProvidesNavigationMenuItemBadge>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) VSelectorViewBase *selector;
@property (nonatomic) BOOL didShowInitial;
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic) NSInteger badgeNumber;
@property (nonatomic, copy) VNavigationMenuItemBadgeNumberUpdateBlock badgeNumberUpdateBlock;

@end

static NSString * const kCellReuseID = @"kCellReuseID";
static NSString * const kScreensKey = @"screens";
static NSString * const kSelectorKey =  @"selector";
static NSString * const kInitialKey = @"initial";

@implementation VMultipleContainerViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _didShowInitial = NO;
        _selectedIndex = 0;
    }
    return self;
}

#pragma mark VHasManagedDependencies conforming initializer

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [self initWithNibName:nil bundle:nil];
    if (self)
    {
        _dependencyManager = dependencyManager;
        self.viewControllers = [dependencyManager arrayOfSingletonValuesOfType:[UIViewController class] forKey:kScreensKey];
        _selector = [dependencyManager templateValueOfType:[VSelectorViewBase class] forKey:kSelectorKey];
        _selector.viewControllers = _viewControllers;
        _selector.delegate = self;
        self.navigationItem.v_supplementaryHeaderView = _selector;
        self.title = NSLocalizedString([dependencyManager stringForKey:VDependencyManagerTitleKey], @"");
        
        __weak typeof(self) weakSelf = self;
        VNavigationMenuItemBadgeNumberUpdateBlock block = ^(NSInteger badgeNumber)
        {
            [weakSelf updateBadge];
        };
        for (UIViewController *vc in _viewControllers)
        {
            if ([vc conformsToProtocol:@protocol(VProvidesNavigationMenuItemBadge)])
            {
                UIViewController<VProvidesNavigationMenuItemBadge> *viewController = (id)vc;
                viewController.badgeNumberUpdateBlock = block;
            }
        }
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)loadView
{
    self.view = [[UIView alloc] init];
    
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.flowLayout.sectionInset = UIEdgeInsetsZero;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.scrollEnabled = NO;
    collectionView.scrollsToTop = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellReuseID];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(collectionView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(collectionView)]];
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( !self.didShowInitial )
    {
        UIViewController *initialViewController = [self.dependencyManager singletonObjectOfType:[UIViewController class] forKey:kInitialKey];
        NSUInteger index = 0;
        if ( initialViewController != nil )
        {
            index = [self.viewControllers indexOfObject:initialViewController];
            if ( index == NSNotFound )
            {
                index = 0;
            }
        }
        [self displayViewControllerAtIndex:index animated:NO isDefaultSelection:YES];
        [self.selector setActiveViewControllerIndex:index];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGSize newItemSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(self.collectionView.bounds) - 1);
    if ( !CGSizeEqualToSize(newItemSize, self.flowLayout.itemSize) )
    {
        self.flowLayout.itemSize = newItemSize;
        [self displayViewControllerAtIndex:self.selector.activeViewControllerIndex animated:NO isDefaultSelection:YES];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ( !self.didShowInitial )
    {
        if ( !self.isInitialViewController )
        {
            [self.collectionView reloadData];
        }
        self.didShowInitial = YES;
    }
    
    id<VMultipleContainerChild> child = self.viewControllers[ self.selector.activeViewControllerIndex ];
    [child multipleContainerDidSetSelected:YES];
}

#pragma mark - Rotation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Properties

- (void)setViewControllers:(NSArray *)viewControllers
{
    [viewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop)
     {
         NSParameterAssert( [viewController isKindOfClass:[UIViewController class]] );
         NSParameterAssert( [viewController conformsToProtocol:@protocol(VMultipleContainerChild)] );
         
         id<VMultipleContainerChild> child = (id<VMultipleContainerChild>)viewController;
         child.multipleContainerChildDelegate = self;
    }];
    
    _viewControllers = [viewControllers copy];
    self.selector.viewControllers = _viewControllers;
    
    [self.collectionView reloadData];
}

- (void)v_setLayoutInsets:(UIEdgeInsets)layoutInsets
{
    [super v_setLayoutInsets:layoutInsets];
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *obj, NSUInteger idx, BOOL *stop)
    {
        if ( [obj isKindOfClass:[UIViewController class]] )
        {
            // TODO: Remove me when we no longer use UITVC
            if ([obj isKindOfClass:[UITableViewController class]])
            {
                obj.v_layoutInsets = UIEdgeInsetsZero;
            }
            else
            {
                obj.v_layoutInsets = layoutInsets;
            }
        }
    }];
}

#pragma mark - Badges

- (void)setBadgeNumber:(NSInteger)badgeNumber
{
    if ( badgeNumber == _badgeNumber )
    {
        return;
    }
    _badgeNumber = badgeNumber;
    
    if ( self.badgeNumberUpdateBlock != nil )
    {
        self.badgeNumberUpdateBlock(self.badgeNumber);
    }
}

- (void)updateBadge
{
    NSInteger count = 0;
    for (UIViewController *vc in _viewControllers)
    {
        if ([vc conformsToProtocol:@protocol(VProvidesNavigationMenuItemBadge)])
        {
            UIViewController<VProvidesNavigationMenuItemBadge> *viewController = (id)vc;
            count += viewController.badgeNumber;
        }
    }
    self.badgeNumber = count;
}

#pragma mark - VMultipleContainer

- (NSArray *)children
{
    return self.viewControllers;
}

- (void)selectChild:(id<VMultipleContainerChild>)child
{
    NSUInteger index = [self.viewControllers indexOfObject:child];
    if ( index == NSNotFound )
    {
        index = 0;
    }
    [self displayViewControllerAtIndex:index animated:NO isDefaultSelection:YES];
    [self.selector setActiveViewControllerIndex:index];
    [self.v_navigationController setNavigationBarHidden:NO];
}

#pragma mark - VMultipleContainerChildDelegate

- (UINavigationItem *)parentNavigationItem
{
    return self.navigationItem;
}

#pragma mark - VAuthorizationContextProvider

- (BOOL)requiresAuthorization
{
    if ([self.viewControllers[self.selectedIndex] conformsToProtocol:@protocol(VAuthorizationContextProvider)])
    {
        UIViewController<VAuthorizationContextProvider> *viewController = self.viewControllers[self.selectedIndex];
        return [viewController requiresAuthorization];
    }
    return NO;
}

- (VAuthorizationContext)authorizationContext
{
    if ([self.viewControllers[self.selectedIndex] conformsToProtocol:@protocol(VAuthorizationContextProvider)])
    {
        UIViewController<VAuthorizationContextProvider> *viewController = self.viewControllers[self.selectedIndex];
        return [viewController authorizationContext];
    }
    return VAuthorizationContextDefault;
}

#pragma mark -

- (UIViewController *)viewControllerAtIndexPath:(NSIndexPath *)indexPath
{
    return self.viewControllers[indexPath.item];
}

- (void)displayViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated isDefaultSelection:(BOOL)isDefaultSelection
{
    self.selectedIndex = index;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:animated];
    
    id<VMultipleContainerChild> viewController = self.viewControllers[ index ];
    [viewController multipleContainerDidSetSelected:isDefaultSelection];
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = [self viewControllerAtIndexPath:indexPath];
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (NSInteger)self.viewControllers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseID forIndexPath:indexPath];
    UIViewController *viewController = [self viewControllerAtIndexPath:indexPath];

    UIView *viewControllerView = viewController.view;
    
    [self addChildViewController:viewController];
    viewControllerView.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:viewControllerView];
    [viewController didMoveToParentViewController:self];
    
    // TODO: Remove me once we no longer use UITVC sÜper hacky
    if ([viewController isKindOfClass:[UITableViewController class]])
    {
        viewController.v_layoutInsets = UIEdgeInsetsZero;
        [cell.contentView v_addFitToParentConstraintsToSubview:viewControllerView
                                                       leading:self.v_layoutInsets.left
                                                      trailing:self.v_layoutInsets.right
                                                           top:self.v_layoutInsets.top
                                                        bottom:self.v_layoutInsets.bottom];
    }
    else
    {
        viewController.v_layoutInsets = self.v_layoutInsets;
        [cell.contentView v_addFitToParentConstraintsToSubview:viewControllerView];
    }

    return cell;
}

#pragma mark - VViewSelectorViewControllerDelegate methods

- (void)viewSelector:(VSelectorViewBase *)viewSelector didSelectViewControllerAtIndex:(NSUInteger)index
{
    [self displayViewControllerAtIndex:index animated:NO isDefaultSelection:NO];
}

@end
