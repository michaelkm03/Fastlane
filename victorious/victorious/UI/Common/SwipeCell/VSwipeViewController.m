//
//  VSwipeView.m
//  SwipeCell
//
//  Created by Patrick Lynch on 12/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSwipeViewController.h"
#import "VUtilityButtonsViewController.h"
#import "UIView+Autolayout.h"
#import "VSwipeView.h"

@interface VSwipeViewController () <UIScrollViewDelegate, VUtilityButtonsViewControllerDelegate>

@property (nonatomic, assign) CGPoint previousContentOffset;
@property (nonatomic, assign) CGPoint scrollDirection;
@property (nonatomic, assign) BOOL isShowingUtilityButtons;

@property (nonatomic, strong) UIButton *blockerButtonOverlay;

@property (strong, nonatomic) VUtilityButtonsViewController *utilityButtonsViewController;

// The subview of the scroll view drives the scroll view's content size
@property (strong, nonatomic) UIView *contentContainerView;

// A scroll view that provides the swipe interaction with animation
// that follows the scroll views built-in bouncing
@property (strong, nonatomic) UIScrollView *scrollView;

// This view occupies the space to the left of the cell when swiping to prevent
// background content from showing through
@property (strong, nonatomic) UIView *leftGutterView;
@property (strong, nonatomic) NSLayoutConstraint *leftGutterViewWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *leftGutterViewLeadingConstraint;

@property (strong, nonatomic) NSLayoutConstraint *contentContainerViewWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *collectionViewWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *collectionViewTrailingConstraint;

@property (nonatomic, assign) CGRect startingFrame;

@end

@implementation VSwipeViewController

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self)
    {
        _startingFrame = frame;
    }
    return self;
}

- (void)loadView
{
    self.view = [[VSwipeView alloc] initWithFrame:self.startingFrame];
}

#pragma mark - Public

- (VSwipeView *)swipeView
{
    return (VSwipeView *)self.view;
}

- (void)hideUtilityButtons
{
    self.blockerButtonOverlay.hidden = YES;
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)showUtilityButtonsAnimated:(BOOL)animated
{
    CGFloat buttonWidth = [self.cellDelegate utilityButtonWidth];
    NSUInteger buttonCount = [self.cellDelegate numberOfUtilityButtons];
    CGFloat maxContentOffsetX = buttonWidth * buttonCount;
    [self.scrollView setContentOffset:CGPointMake( maxContentOffsetX, 0.0f ) animated:animated];
}

- (void)showUtilityButtons
{
    [self showUtilityButtonsAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createScrollView];
    [self createContentContainerView];
    [self createLeftGutterView];
    
    [self setScrollViewContraints];
    [self setContentContainerConstraints];
    [self setLeftGutterViewConstraints];
}

- (void)setCellDelegate:(id<VSwipeViewCellDelegate>)cellDelegate
{
    if ( _cellDelegate != nil )
    {
        return;
    }
    
    _cellDelegate = cellDelegate;
    
    CGFloat buttonWidth = [_cellDelegate utilityButtonWidth];
    NSUInteger buttonCount = [_cellDelegate numberOfUtilityButtons];
    self.contentContainerViewWidthConstraint.constant = buttonWidth * buttonCount;
    
    CGRect startingFrame = CGRectMake( CGRectGetWidth(self.view.frame), 0.0f, 0.0f, CGRectGetHeight(self.view.frame));
    self.utilityButtonsViewController = [[VUtilityButtonsViewController alloc] initWithFrame:startingFrame];
    self.utilityButtonsViewController.delegate = self;
    [self.view addSubview:self.utilityButtonsViewController.view];
    [self setUtilityButtonViewConstraintsWithView:self.utilityButtonsViewController.view
                                        superview:self.view ];
    
    [self createBlockerButtonOverlay];
    [self setBlockerButtonOverlayConstraints];
    
    [self reset];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.cellDelegate.parentCellView addGestureRecognizer:swipe];
}

- (void)onSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    if ( !self.isShowingUtilityButtons )
    {
        [self showUtilityButtonsAnimated:YES];
    }
}

- (UIView *)utilityButtonsContainer
{
    return self.utilityButtonsViewController.view;
}

#pragma mark - Subview creation

- (void)createBlockerButtonOverlay
{
    CGRect frame = self.cellDelegate.parentCellView.bounds;
    frame.size.height = 20.0;
    self.blockerButtonOverlay = [[UIButton alloc] initWithFrame:frame];
    self.blockerButtonOverlay.backgroundColor = [UIColor clearColor];
    self.blockerButtonOverlay.hidden = YES;
    self.blockerButtonOverlay.translatesAutoresizingMaskIntoConstraints = NO;
    [self.blockerButtonOverlay addTarget:self action:@selector(blockerButtonOverlayTapped:) forControlEvents:UIControlEventTouchDown];
    [self.cellDelegate.parentCellView addSubview:self.blockerButtonOverlay];
    [self.cellDelegate.parentCellView bringSubviewToFront:self.blockerButtonOverlay];
    [self.cellDelegate.parentCellView v_addFitToParentConstraintsToSubview:self.blockerButtonOverlay];
}

- (void)createLeftGutterView
{
    CGRect startingFrame = CGRectMake( 0.0, 0.0, 0.0, CGRectGetHeight(self.view.frame));
    self.leftGutterView = [[UIView alloc] initWithFrame:startingFrame];
    [self.view addSubview:self.leftGutterView];
}

- (void)createScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    self.scrollView.scrollEnabled = YES;
    self.scrollView.bounces = YES;
    self.scrollView.delaysContentTouches = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
}

- (void)createContentContainerView
{
    self.contentContainerView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.scrollView addSubview:self.contentContainerView];
}

- (void)blockerButtonOverlayTapped:(UIButton *)blockerButtonOverlay
{
    [self hideUtilityButtons];
}

#pragma mark - Constraints

- (void)setBlockerButtonOverlayConstraints
{
    NSDictionary *views = @{ @"button" : self.blockerButtonOverlay };
    self.leftGutterView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cellDelegate.parentCellView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|"
                                                                                             options:kNilOptions
                                                                                             metrics:nil
                                                                                               views:views]];
    [self.cellDelegate.parentCellView  addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[button]|"
                                                                                              options:kNilOptions
                                                                                              metrics:nil
                                                                                                views:views]];
}

- (void)setLeftGutterViewConstraints
{
    NSDictionary *views = @{ @"leftGutterView" : self.leftGutterView };
    self.leftGutterView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftGutterView]|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:views]];
    NSArray *constraintsH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftGutterView]"
                                                                    options:kNilOptions
                                                                    metrics:nil
                                                                      views:views];
    self.leftGutterViewLeadingConstraint = constraintsH.firstObject;
    [self.view addConstraints:constraintsH];
    self.leftGutterViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.leftGutterView
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0f
                                                                       constant:50.0f];
    
    [self.leftGutterView addConstraint:self.leftGutterViewWidthConstraint];
}

- (void)setScrollViewContraints
{
    NSDictionary *views = @{ @"scrollView" : self.scrollView };
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|"
                                                                          options:kNilOptions
                                                                          metrics:nil
                                                                            views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|"
                                                                          options:kNilOptions
                                                                          metrics:nil
                                                                            views:views]];
}

- (void)setUtilityButtonViewConstraintsWithView:(UIView *)collectionView superview:(UIView *)superview
{
    NSParameterAssert( collectionView.superview == superview );
    
    NSDictionary *views = @{ @"collectionView" : collectionView };
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:views]];
    NSArray *constraintsH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[collectionView]|"
                                                                    options:kNilOptions
                                                                    metrics:nil
                                                                      views:views];
    self.collectionViewTrailingConstraint = constraintsH.firstObject;
    [superview addConstraints:constraintsH];
    self.collectionViewWidthConstraint = [NSLayoutConstraint constraintWithItem:collectionView
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0f
                                                                       constant:0.0f];
    
    [collectionView addConstraint:self.collectionViewWidthConstraint];
}

- (void)setContentContainerConstraints
{
    NSDictionary *views = @{ @"contentContainerView" : self.contentContainerView };
    self.contentContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentContainerView]|"
                                                                            options:kNilOptions
                                                                            metrics:nil
                                                                              views:views]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentContainerView]|"
                                                                            options:kNilOptions
                                                                            metrics:nil
                                                                              views:views]];
    
    // Equal heights
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentContainerView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.scrollView
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:1.0f
                                                                 constant:0.0f]];
    
     // Equal widths, and keep the reference
    self.contentContainerViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.contentContainerView
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.scrollView
                                                                            attribute:NSLayoutAttributeWidth
                                                                           multiplier:1.0f
                                                                             constant:0.0f];
    [self.scrollView addConstraint:self.contentContainerViewWidthConstraint];
}

#pragma mark - VUtilityButtonsViewControllerDelegate

- (void)utilityButtonSelected
{
    [self hideUtilityButtons];
}

#pragma mark - State management

- (void)reset
{
    UIView *view = self.cellDelegate.parentCellView;
    view.transform = CGAffineTransformIdentity;
    [self.scrollView setContentOffset:CGPointZero animated:NO];
    self.blockerButtonOverlay.hidden = YES;
}

- (void)utlityButtonsDidHide
{
    self.blockerButtonOverlay.hidden = YES;
}

- (void)utilityButtonsDidShow
{
    self.blockerButtonOverlay.hidden = NO;
    [self.controllerDelegate cellWillShowUtilityButtons:self.cellDelegate.parentCellView];
}

- (void)updateGutterViews:(CGFloat)gutterWidth
{
    // Gutter width is driven by the scroll view's content offset, and all functionality
    // in this method animates elements to follow it to that scroll view animation properties,
    // such as bouncing and deceleration are applied
    
    // Size the collection view containing utility buttons to fit the space created when scrolled
    self.collectionViewWidthConstraint.constant = MAX( gutterWidth, 0.0f );
    self.collectionViewTrailingConstraint.constant = -gutterWidth;
    
    [self.utilityButtonsViewController constraintsDidUpdate];
    
    // Size the gutter view fit the space created when scrolled (mainly to avoid seeing content behind cell)
    self.leftGutterViewWidthConstraint.constant = MAX( -gutterWidth, 0.0f );
    self.leftGutterViewLeadingConstraint.constant = gutterWidth;
    self.leftGutterView.backgroundColor = [self.controllerDelegate backgroundColorForGutter];
    
    // Slide the cell to the side following the scrollview
    UIView *view = self.cellDelegate.parentCellView;
    view.transform = CGAffineTransformMakeTranslation( -gutterWidth, 0.0f );
    
    self.swipeView.activeOutOfBoundsArea = self.utilityButtonsViewController.view.frame;
}

- (void)updateScrollState:(UIScrollView *)scrollView
{
    // Calculate current scroll direction based on comparison to previous contentOffset
    self.scrollDirection = CGPointMake(scrollView.contentOffset.x - self.previousContentOffset.x,
                                       scrollView.contentOffset.y - self.previousContentOffset.y );
    self.previousContentOffset = scrollView.contentOffset;
    
    // Check on the appearance or disappearance of the utility buttons and
    // call delegate methods to allow calling code to respond
    BOOL wasShwoing = self.isShowingUtilityButtons;
    self.isShowingUtilityButtons = scrollView.contentOffset.x > 0.0f;
    if ( !wasShwoing && self.isShowingUtilityButtons )
    {
        [self utilityButtonsDidShow];
    }
    if ( wasShwoing && !self.isShowingUtilityButtons )
    {
        [self utlityButtonsDidHide];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat gutterWidth = ceil( scrollView.contentOffset.x );
    [self updateGutterViews:gutterWidth];
    [self updateScrollState:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    BOOL isMovingRight = self.scrollDirection.x < 0.0f;
    if ( isMovingRight )
    {
        [self hideUtilityButtons];
    }
    else
    {
        [self showUtilityButtons];
    }
}

@end
