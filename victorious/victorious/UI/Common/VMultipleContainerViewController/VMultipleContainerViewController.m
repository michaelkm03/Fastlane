//
//  VMultipleContainerViewController.m
//  victorious
//
//  Created by Josh Hinman on 12/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIViewController+VLayoutInsets.h"
#import "VDependencyManager+NavigationBar.h"
#import "VMultipleContainer.h"
#import "VMultipleContainerViewController.h"
#import "VNavigationController.h"
#import "VSelectorViewBase.h"
#import "VStreamCollectionViewController.h"
#import "VAuthorizationContext.h"
#import "VNavigationDestination.h"
#import "VProvidesNavigationMenuItemBadge.h"
#import "UIView+AutoLayout.h"
#import "VCoachmarkDisplayResponder.h"
#import "VCoachmarkDisplayer.h"
#import "VDependencyManager+VNavigationItem.h"
#import "victorious-Swift.h"

@interface VMultipleContainerViewController () <UICollectionViewDataSource, UICollectionViewDelegate, VSelectorViewDelegate, VMultipleContainerChildDelegate, VProvidesNavigationMenuItemBadge, VCoachmarkDisplayResponder, VCoachmarkDisplayer>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) VSelectorViewBase *selector;
@property (nonatomic) BOOL didShowInitial;
@property (nonatomic) NSUInteger selectedIndex;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.selector = [self.dependencyManager templateValueOfType:[VSelectorViewBase class] forKey:kSelectorKey];
    self.selector.viewControllers = self.viewControllers;
    self.selector.delegate = self;
    self.navigationItem.v_supplementaryHeaderView = self.selector;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dependencyManager configureNavigationItem:self.navigationItem];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGSize newItemSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(self.collectionView.bounds) - 1);
    if ( !CGSizeEqualToSize(newItemSize, self.flowLayout.itemSize) )
    {
        self.flowLayout.itemSize = newItemSize;
        [self updateBadge];
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
        if ([self.viewControllers.firstObject isKindOfClass:[UITableViewController class]])
        {
            [self.collectionView reloadData];
        }
        
        [self displayViewControllerAtIndex:index animated:NO isDefaultSelection:YES];
        [self.selector setActiveViewControllerIndex:index];
        
        self.didShowInitial = YES;
    }
}

#pragma mark - Rotation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
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
    
    self.selector.viewControllers = _viewControllers;
    
    [self.collectionView reloadData];
}

- (void)v_setLayoutInsets:(UIEdgeInsets)layoutInsets
{
    [super v_setLayoutInsets:layoutInsets];
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *obj, NSUInteger index, BOOL *stop)
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

- (void)updateBadge
{
    [self.selector updateSelectorTitle];
}

#pragma mark - VProvidesNavigationMenuItemBadge

@synthesize badgeNumberUpdateBlock = _badgeNumberUpdateBlock;

- (void)setBadgeNumberUpdateBlock:(VNavigationMenuItemBadgeNumberUpdateBlock)badgeNumberUpdateBlock
{
    _badgeNumberUpdateBlock = nil;
    __weak VMultipleContainerViewController *weakSelf = self;
    for (UIViewController *vc in _viewControllers)
    {
        if ([vc conformsToProtocol:@protocol(VProvidesNavigationMenuItemBadge)])
        {
            UIViewController<VProvidesNavigationMenuItemBadge> *viewController = (id)vc;
            viewController.badgeNumberUpdateBlock = ^(NSInteger badgeNumber)
            {
                VMultipleContainerViewController *strongSelf = weakSelf;
                if (strongSelf == nil)
                {
                    return;
                }
                
                badgeNumberUpdateBlock(strongSelf.badgeNumber);
            };
        }
    }
}

- (NSInteger)badgeNumber
{
    NSInteger total = 0;
    for (UIViewController *vc in _viewControllers)
    {
        if ([vc conformsToProtocol:@protocol(VProvidesNavigationMenuItemBadge)])
        {
            id<VProvidesNavigationMenuItemBadge> badgeProvider = (id<VProvidesNavigationMenuItemBadge>)vc;
            total += [badgeProvider badgeNumber];
        }
    }
    return total;
}

#pragma mark - VCoachmarkDisplayResponder

- (void)findOnScreenMenuItemWithIdentifier:(NSString *)identifier andCompletion:(VMenuItemDiscoveryBlock)completion
{
    NSParameterAssert(completion != nil);
    for ( NSUInteger index = 0; index < self.viewControllers.count; index++ )
    {
        UIViewController *viewController = self.viewControllers[index];
        if ( [viewController conformsToProtocol:@protocol(VCoachmarkDisplayer)] )
        {
            UIViewController <VCoachmarkDisplayer> *coachmarkDisplayer = (UIViewController <VCoachmarkDisplayer> *)viewController;
            if ( [coachmarkDisplayer respondsToSelector:@selector(selectorIsVisible)] )
            {
                if ( ![coachmarkDisplayer selectorIsVisible] )
                {
                    //The current displayer doesn't have a visible selector, stop looking for coachmarks it can display
                    break;
                }
            }

            //View controller can display a coachmark
            NSString *screenIdenifier = [coachmarkDisplayer screenIdentifier];
            if ( [identifier isEqualToString:screenIdenifier] )
            {
                //Found the screen that we're supposed to point out
                CGRect frame = [self.selector frameOfButtonAtIndex:index];
                completion(YES, frame);
                return;
            }
        }
    }
    
    UIResponder <VCoachmarkDisplayResponder> *nextResponder = [self.nextResponder targetForAction:@selector(findOnScreenMenuItemWithIdentifier:andCompletion:) withSender:nil];
    if ( nextResponder == nil )
    {
        completion(NO, CGRectZero);
    }
    else
    {
        [nextResponder findOnScreenMenuItemWithIdentifier:identifier andCompletion:completion];
    }
}

#pragma mark - VCoachmarkDisplayer

- (NSString *)screenIdentifier
{
    return [self.dependencyManager stringForKey:VDependencyManagerIDKey];
}

#pragma mark - VTabMenuContainedViewControllerNavigation

- (void)reselected
{
    id childViewController = [self children][self.selectedIndex];
    if ( [childViewController conformsToProtocol:@protocol(VTabMenuContainedViewControllerNavigation)] )
    {
        [((id<VTabMenuContainedViewControllerNavigation>)childViewController) reselected];
    }
}

@end
