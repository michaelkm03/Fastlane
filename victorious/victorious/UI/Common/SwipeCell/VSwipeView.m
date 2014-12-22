//
//  VSwipeView.m
//  SwipeCell
//
//  Created by Patrick Lynch on 12/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSwipeView.h"

static const CGFloat kCollectionViewSectionsCount = 1;

@interface VSwipeView () <UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGPoint previousContentOffset;
@property (nonatomic, assign) CGPoint scrollDirection;
@property (nonatomic, assign) BOOL isShowingUtilityButtons;

@property (nonatomic, strong) UIButton *blockerButtonOverlay;

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *collectionViewLayout;

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

@end

@implementation VSwipeView

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass( [self class] );
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    [self createScrollView];
    [self createContentContainerView];
    [self createUtilityButtonsCollectionView];
    [self createLeftGutterView];
    
    [self setScrollViewContraints];
    [self setContentContainerConstraints];
    [self setCollectionViewConstraints];
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
    
    [self createBlockerButtonOverlay];
    [self setBlockerButtonOverlayConstraints];
    
    [self.scrollView layoutIfNeeded];
}

- (void)addConstraintsToFitContainerView:(UIView *)containerView
{
    NSParameterAssert( containerView == self.superview );
    
    NSDictionary *views = @{ @"view" : self };
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                          options:kNilOptions
                                                                          metrics:nil
                                                                            views:views]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"
                                                                          options:kNilOptions
                                                                          metrics:nil
                                                                            views:views]];
}

- (UIView *)utilityButtonsContainer
{
    return self.collectionView;
}

- (void)createBlockerButtonOverlay
{
    self.blockerButtonOverlay = [[UIButton alloc] initWithFrame:self.cellDelegate.parentCellView.bounds];
    self.blockerButtonOverlay.backgroundColor = [UIColor clearColor];
    self.blockerButtonOverlay.hidden = YES;
    [self.blockerButtonOverlay addTarget:self action:@selector(blockerButtonOverlayTapped:) forControlEvents:UIControlEventTouchDown];
    [self.cellDelegate.parentCellView addSubview:self.blockerButtonOverlay];
    [self.cellDelegate.parentCellView bringSubviewToFront:self.blockerButtonOverlay];
}

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

- (void)createLeftGutterView
{
    CGRect startingFrame = CGRectMake( 0.0, 0.0, 0.0, CGRectGetHeight(self.frame));
    self.leftGutterView = [[UIView alloc] initWithFrame:startingFrame];
    [self addSubview:self.leftGutterView];
}

- (void)setLeftGutterViewConstraints
{
    NSDictionary *views = @{ @"leftGutterView" : self.leftGutterView };
    self.leftGutterView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftGutterView]|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:views]];
    NSArray *constraintsH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftGutterView]"
                                                                    options:kNilOptions
                                                                    metrics:nil
                                                                      views:views];
    self.leftGutterViewLeadingConstraint = constraintsH.firstObject;
    [self addConstraints:constraintsH];
    self.leftGutterViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.leftGutterView
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0f
                                                                       constant:50.0f];
    
    [self.leftGutterView addConstraint:self.leftGutterViewWidthConstraint];
}

- (void)createScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    self.scrollView.scrollEnabled = YES;
    self.scrollView.bounces = YES;
    self.scrollView.delaysContentTouches = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
}

- (void)createContentContainerView
{
    self.contentContainerView = [[UIView alloc] initWithFrame:self.frame];
    [self.scrollView addSubview:self.contentContainerView];
}

- (void)createUtilityButtonsCollectionView
{
    self.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionViewLayout.sectionInset = UIEdgeInsetsZero;
    self.collectionViewLayout.minimumInteritemSpacing = 0.0;
    
    CGRect startingFrame = CGRectMake( CGRectGetWidth(self.frame), 0.0f, 0.0f, CGRectGetHeight(self.frame));
    self.collectionView = [[UICollectionView alloc] initWithFrame:startingFrame
                                             collectionViewLayout:self.collectionViewLayout];
    self.collectionView.scrollEnabled = NO;
    self.collectionView.delaysContentTouches = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    NSString *reuseIdentifier = [VUtilityButtonCell reuseIdentifier];
    UINib *nib = [UINib nibWithNibName:reuseIdentifier bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:reuseIdentifier];
    
    [self addSubview:self.collectionView];
}

- (void)blockerButtonOverlayTapped:(UIButton *)blockerButtonOverlay
{
    [self hideUtilityButtons];
}

#pragma mark - Constraints

- (void)setScrollViewContraints
{
    NSDictionary *views = @{ @"scrollView" : self.scrollView };
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|"
                                                                          options:kNilOptions
                                                                          metrics:nil
                                                                            views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|"
                                                                          options:kNilOptions
                                                                          metrics:nil
                                                                            views:views]];
}

- (void)setCollectionViewConstraints
{
    NSDictionary *views = @{ @"collectionView" : self.collectionView };
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:views]];
    NSArray *constraintsH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[collectionView]|"
                                                                    options:kNilOptions
                                                                    metrics:nil
                                                                      views:views];
    self.collectionViewTrailingConstraint = constraintsH.firstObject;
    [self addConstraints:constraintsH];
    self.collectionViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0f
                                                                       constant:0.0f];
    
    [self.collectionView addConstraint:self.collectionViewWidthConstraint];
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

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if ( CGRectContainsPoint( self.collectionView.frame, point) )
    {
        return YES;
    }
    
    return [super pointInside:point withEvent:event];
}

#pragma mark - State management

- (void)reset
{
    UIView *view = self.cellDelegate.parentCellView;
    view.transform = CGAffineTransformIdentity;
    [self.scrollView setContentOffset:CGPointZero animated:NO];
}

- (void)hideUtilityButtons
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)showUtilityButtons
{
    CGFloat buttonWidth = [self.cellDelegate utilityButtonWidth];
    NSUInteger buttonCount = [self.cellDelegate numberOfUtilityButtons];
    CGFloat maxContentOffsetX = buttonWidth * buttonCount;
    [self.scrollView setContentOffset:CGPointMake( maxContentOffsetX, 0.0f ) animated:YES];
}

- (void)updateGutterViews:(CGFloat)gutterWidth
{
    // Size the collection view containing utility buttons to fit the space created when scrolled
    self.collectionViewWidthConstraint.constant = MAX( gutterWidth, 0.0f );
    self.collectionViewTrailingConstraint.constant = -gutterWidth;
    [self.collectionViewLayout invalidateLayout];
    self.collectionViewLayout.sectionInset = UIEdgeInsetsZero;
    
    // Size the gutter view fit the space created when scrolled (mainly to avoid seeing content behind cell)
    self.leftGutterViewWidthConstraint.constant = MAX( -gutterWidth, 0.0f );
    self.leftGutterViewLeadingConstraint.constant = gutterWidth;
    self.leftGutterView.backgroundColor = [self.controllerDelegate backgroundColorForGutter];
}

- (void)updateScrollState:(UIScrollView *)scrollView didHide:(BOOL *)didHide didShow:(BOOL *)didShow
{
    // Calculate current scroll direction based on comparising to previous contentOffset
    self.scrollDirection = CGPointMake(scrollView.contentOffset.x - self.previousContentOffset.x,
                                       scrollView.contentOffset.y - self.previousContentOffset.y );
    self.previousContentOffset = scrollView.contentOffset;
    
    // Allow the delegate to respond to the opening of the utlity buttons
    BOOL wasShwoing = self.isShowingUtilityButtons;
    self.isShowingUtilityButtons = scrollView.contentOffset.x > 0.0f;
    *didShow = !wasShwoing && self.isShowingUtilityButtons;
    *didHide = wasShwoing && !self.isShowingUtilityButtons;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat gutterWidth = ceil( scrollView.contentOffset.x );
    [self updateGutterViews:gutterWidth];
    
    BOOL didShow = NO;
    BOOL didHide = NO;
    [self updateScrollState:scrollView didHide:&didHide didShow:&didShow];
    
    if ( didShow )
    {
        [self.controllerDelegate cellWillShowUtilityButtons:self.cellDelegate.parentCellView];
    }
    
    // Slide the cell to the side following the scrollview
    UIView *view = self.cellDelegate.parentCellView;
    view.transform = CGAffineTransformMakeTranslation( -gutterWidth, 0.0f );
    if ( didShow )
    {
        self.blockerButtonOverlay.hidden = NO;
    }
    else if ( didHide )
    {
        self.blockerButtonOverlay.hidden = YES;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ( self.scrollDirection.x < 0.0f )
    {
        [self hideUtilityButtons];
    }
    else
    {
        [self showUtilityButtons];
    }
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VUtilityButtonCell *buttonCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VUtilityButtonCell reuseIdentifier] forIndexPath:indexPath];
    buttonCell.iconImageView.image = [self.cellDelegate iconImageForButtonAtIndex:indexPath.row];
    buttonCell.backgroundColor = [self.cellDelegate backgroundColorForButtonAtIndex:indexPath.row];
    buttonCell.intendedFullWidth = [self.cellDelegate utilityButtonWidth];
    return buttonCell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return kCollectionViewSectionsCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.cellDelegate numberOfUtilityButtons];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = CGRectGetHeight( self.collectionView.frame );
    CGFloat totalWidth = CGRectGetWidth( self.collectionView.frame);
    NSUInteger buttonCount = [self.cellDelegate numberOfUtilityButtons];
    CGFloat width = totalWidth / (CGFloat)buttonCount;
    return CGSizeMake( width, height );
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VUtilityButtonCell *buttonCell = (VUtilityButtonCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self.cellDelegate utilityButton:buttonCell selectedAtIndex:indexPath.row];
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    VUtilityButtonCell *buttonCell = (VUtilityButtonCell *)[collectionView cellForItemAtIndexPath:indexPath];
    buttonCell.highlighted = YES;
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    VUtilityButtonCell *buttonCell = (VUtilityButtonCell *)[collectionView cellForItemAtIndexPath:indexPath];
    buttonCell.highlighted = NO;
}

@end
