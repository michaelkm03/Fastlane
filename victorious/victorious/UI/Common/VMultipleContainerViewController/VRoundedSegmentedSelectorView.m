//
//  VRoundedSegmentedSelectorView.m
//  victorious
//
//  Created by Sharif Ahmed on 3/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VRoundedSegmentedSelectorView.h"
#import "VDependencyManager.h"
#import "VExtendedView.h"
#import "UIImage+ImageCreation.h"
#import "UIView+AutoLayout.h"

static CGFloat const kVBarHeight = 40.0f;
static CGFloat const kVPillHeight = 29.0f;
static CGFloat const kVHorizontalInset = 10.0f;
static CGFloat const kVSelectionAnimationDuration = 0.35f;
static CGFloat const kVBoldFontPointSize = 14.0f;
static CGFloat const kVRegularFontPointSizeSubtractor = 1.0f;

@interface VRoundedSegmentedSelectorView ()

@property (nonatomic, assign) NSUInteger realActiveViewControllerIndex;
@property (nonatomic, strong) VExtendedView *pillView;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) UIImageView *selectionView;
@property (nonatomic, strong) NSLayoutConstraint *selectionViewLeftConstraint;
@property (nonatomic, strong) NSLayoutConstraint *selectionViewWidthConstraint;
@property (nonatomic, strong) UIColor *pillColor;

@property (nonatomic, strong) UIImageView *highlightMask;

@end

@implementation VRoundedSegmentedSelectorView

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if (self != nil)
    {
        self.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    }
    return self;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    [super setViewControllers:viewControllers];
    [self setupWithCurrentViewControllers];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, kVBarHeight);
}

#pragma mark - activeViewControllerIndex updating

- (void)setActiveViewControllerIndex:(NSUInteger)activeViewControllerIndex
{
    self.realActiveViewControllerIndex = activeViewControllerIndex;
    if ( [self hasValidLayout] )
    {
        [self updateSelectionViewConstraintAnimated:YES];
    }
}

//Must implement, otherwise NSNotFound is returned
- (NSUInteger)activeViewControllerIndex
{
    return self.realActiveViewControllerIndex;
}

- (void)pressedHeaderButton:(UIButton *)button
{
    if ( self.activeViewControllerIndex == (NSUInteger)button.tag )
    {
        return;
    }
    
    [self setActiveViewControllerIndex:button.tag];
    
    if ( [self.delegate respondsToSelector:@selector(viewSelector:didSelectViewControllerAtIndex:)] )
    {
        [self.delegate viewSelector:self didSelectViewControllerAtIndex:self.realActiveViewControllerIndex];
    }
}

- (void)setupWithCurrentViewControllers
{
    if ( ![self hasValidLayout] )
    {
        return;
    }
    
    [self resetSubviews];
    
    [self addStaticViews];
    
    //Setup the buttons that will allow users to select different streams
    __weak VRoundedSegmentedSelectorView *wSelf = self;
    __block UIButton *priorButton = nil;
    CGFloat cornerRadius = [self pillButtonInset];
    UIColor *buttonSelectionColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    NSDictionary *buttonHorizontalInsetMetrics = @{ @"inset" : @(cornerRadius) };
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop)
     {
         VRoundedSegmentedSelectorView *sSelf = wSelf;
         if ( sSelf == nil )
         {
             return;
         }
         
         //Note: Setting the button's text color to the "highlighted" color here so that it appears that way in the snapshot below
         UIButton *button = [self newButtonWithTitle:viewController.title font:[[self.dependencyManager fontForKey:VDependencyManagerHeading3FontKey] fontWithSize:kVBoldFontPointSize] andTextColor:buttonSelectionColor];
         button.tag = idx;
         [button addTarget:sSelf action:@selector(pressedHeaderButton:) forControlEvents:UIControlEventTouchUpInside];
         
         [sSelf addButton:button toContainer:sSelf.pillView afterPriorButton:priorButton withMetrics:buttonHorizontalInsetMetrics isLast:idx == sSelf.viewControllers.count - 1];
         
         priorButton = button;
         
         [sSelf.buttons addObject:button];
     }];
    
    [self.pillView layoutIfNeeded];
    
    //Take a snapshot of the buttons in their current state so that our mask view will mask all of the button texts as it is moved across a single view
    UIGraphicsBeginImageContextWithOptions(self.pillView.bounds.size, NO, 0.0);
    [self.pillView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *barScreenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self addSelectionView];
    
    //Reset buttons to proper "unhighlighted" color
    for (UIButton *button in self.buttons)
    {
        [button setTitleColor:self.pillColor forState:UIControlStateNormal];
        [[button titleLabel] setFont:[[self.dependencyManager fontForKey:VDependencyManagerHeading4FontKey] fontWithSize:kVBoldFontPointSize - kVRegularFontPointSizeSubtractor]];
        [button setTitleColor:[self.pillColor colorWithAlphaComponent:0.5f] forState:UIControlStateHighlighted];
    }
    
    [self addHighlightViewWithSnapshot:barScreenShot];
    
    if ( _realActiveViewControllerIndex >= self.buttons.count )
    {
        _realActiveViewControllerIndex = 0;
    }
    [self updateSelectionViewConstraintAnimated:NO];
}

- (BOOL)hasValidLayout
{
    return !CGRectEqualToRect(CGRectZero, self.bounds);
}

- (void)resetSubviews
{
    [self removeConstraints:self.constraints];
    [self.pillView removeConstraints:self.pillView.constraints];
    
    //Remove any existing subviews from superview
    for ( UIButton *button in self.buttons )
    {
        [button removeFromSuperview];
    }
    [self.buttons removeAllObjects];
    [self.pillView removeFromSuperview];
}

- (void)addStaticViews
{
    //Create the background view which will house all of the selector views
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [backgroundView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self addSubview:backgroundView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(backgroundView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[backgroundView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundView(barHeight)]|"
                                                                 options:0
                                                                 metrics:@{ @"barHeight" : @(kVBarHeight) }
                                                                   views:views]];
    
    //Setup the pillView that will display the rounded pill on our background
    [backgroundView addSubview:self.pillView];
    NSDictionary *pillViews = @{ @"pill" : self.pillView };
    [backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-inset-[pill]-inset-|"
                                                                           options:0
                                                                           metrics:@{ @"inset" : @(kVHorizontalInset) }
                                                                             views:pillViews]];
    [backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topInset-[pill(pillHeight)]"
                                                                           options:0
                                                                           metrics:@{ @"topInset" : @(3.0f), @"pillHeight" : @(kVPillHeight) }
                                                                             views:pillViews]];
}

- (void)addButton:(UIButton *)button toContainer:(UIView *)container afterPriorButton:(UIButton *)priorButton withMetrics:(NSDictionary *)metrics isLast:(BOOL)isLast
{
    [container addSubview:button];
    NSDictionary *buttonDictionary = NSDictionaryOfVariableBindings(button);
    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|" options:0 metrics:nil views:buttonDictionary]];
    
    if ( priorButton == nil )
    {
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-inset-[button]" options:0 metrics:metrics views:buttonDictionary]];
    }
    else
    {
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[priorButton(==button)][button]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(button, priorButton)]];
    }
    
    if ( isLast )
    {
        //Last label to be created, pin it to the right side of it's superview
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[button]-inset-|" options:0 metrics:metrics views:buttonDictionary]];
    }
}

- (void)addSelectionView
{
    //Now add the selectionView which will show which tab is selected. This must be done after the snapshot otherwise it will appear in the snapshot.
    [self.pillView addSubview:self.selectionView];
    NSDictionary *selectionViews = @{ @"selectionView" : self.selectionView };
    [self.pillView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[selectionView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:selectionViews]];
    CGFloat selectionViewWidth = ( ( CGRectGetWidth(self.bounds) - kVHorizontalInset * 2 - [self pillButtonInset] * 2 ) / self.viewControllers.count ) + [self pillButtonInset] * 2;
    self.selectionViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.selectionView
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.0f
                                                                      constant:selectionViewWidth];
    [self.selectionView addConstraint:self.selectionViewWidthConstraint];
    self.selectionViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.selectionView
                                                                    attribute:NSLayoutAttributeLeft
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.pillView
                                                                    attribute:NSLayoutAttributeLeft
                                                                   multiplier:1.0f
                                                                     constant:0.0f];
    [self.pillView addConstraint:self.selectionViewLeftConstraint];
    [self.selectionView layoutIfNeeded];
}

- (void)addHighlightViewWithSnapshot:(UIImage *)snapshot
{
    //Add the snapshot imageview to our bar
    UIImageView *highlightOverView = [[UIImageView alloc] initWithImage:snapshot];
    [self.pillView addSubview:highlightOverView];
    [self.pillView v_addFitToParentConstraintsToSubview:highlightOverView];
    
    //Create the mask layer that will mask the snapshot of the highlighted text
    self.highlightMask.frame = self.selectionView.bounds;
    highlightOverView.maskView = self.highlightMask;
}

#pragma mark - display updating

- (void)updateSelectionViewConstraintAnimated:(BOOL)animated
{
    CGFloat constriantConstant = [self selectionViewOffsetForIndex:self.activeViewControllerIndex];
    CGRect targetMaskFrame = self.selectionView.frame;
    targetMaskFrame.origin.x = constriantConstant;
    CGFloat targetWidth = [self selectionViewWidthForIndex:self.activeViewControllerIndex];
    targetMaskFrame.size.width = targetWidth;
    if ( animated )
    {
        [UIView animateWithDuration:kVSelectionAnimationDuration
                         animations:^
         {
             self.selectionViewLeftConstraint.constant = constriantConstant;
             self.selectionViewWidthConstraint.constant = targetWidth;
             self.highlightMask.frame = targetMaskFrame;
             [self layoutIfNeeded];
         }];
    }
    else
    {
        self.selectionViewLeftConstraint.constant = constriantConstant;
        self.selectionViewWidthConstraint.constant = targetWidth;
        self.highlightMask.frame = targetMaskFrame;
        [self setNeedsLayout];
    }
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self setupWithCurrentViewControllers];
}

#pragma mark - selectionView updating

- (CGFloat)selectionViewOffsetForIndex:(NSUInteger)index
{
    CGFloat offset = 0;
    for ( NSUInteger i = 0; i < index; i++ )
    {
        offset += [self selectionViewWidthForIndex:i];
    }
    
    if ( index > 0 )
    {
        offset -= [self pillButtonInset];
    }
    
    if ( index == self.viewControllers.count - 1)
    {
        offset -= [self pillButtonInset];
    }
    
    return offset;
}

- (CGFloat)selectionViewWidthForIndex:(NSUInteger)index
{
    UIButton *anyButton = self.buttons.firstObject;
    if ( anyButton != nil )
    {
        CGFloat width = CGRectGetWidth(anyButton.bounds);
        if ( index == 0 || index == self.viewControllers.count - 1 )
        {
            //At an edge, add the corner radius so that the pill fits nicely into the edges
            width += [self pillButtonInset] * 2;
        }
        return width;
    }
    return 0;
}

#pragma mark - lazy inits

- (NSMutableArray *)buttons
{
    if ( _buttons != nil )
    {
        return _buttons;
    }
    
    _buttons = [[NSMutableArray alloc] init];
    return _buttons;
}

- (UIColor *)pillColor
{
    if ( _pillColor )
    {
        return _pillColor;
    }
    _pillColor = self.foregroundColor;
    return _pillColor;
}

- (VExtendedView *)pillView
{
    if ( _pillView )
    {
        return _pillView;
    }
    
    _pillView = [[VExtendedView alloc] init];
    _pillView.translatesAutoresizingMaskIntoConstraints = NO;
    _pillView.borderColor = self.pillColor;
    _pillView.borderWidth = 1.0f;
    _pillView.cornerRadius = kVPillHeight / 2.0f;
    return _pillView;
}

- (CGFloat)pillButtonInset
{
    return self.pillView.cornerRadius / 4.0f;
}

- (UIImageView *)selectionView
{
    if ( _selectionView )
    {
        return _selectionView;
    }
    
    _selectionView = [self newPillImageView];
    return _selectionView;
}

- (UIImageView *)highlightMask
{
    if ( _highlightMask )
    {
        return _highlightMask;
    }
    
    _highlightMask = [self newPillImageView];
    return _highlightMask;
}

#pragma mark - helper view creators

- (UIImageView *)newPillImageView
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage resizeableImageWithColor:self.pillColor]];
    imageView.clipsToBounds = YES;
    imageView.backgroundColor = [UIColor clearColor];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.layer.cornerRadius = self.pillView.cornerRadius;
    return imageView;
}

- (UIButton *)newButtonWithTitle:(NSString *)title font:(UIFont *)font andTextColor:(UIColor *)color
{
    //Create a label, set it's text to the title, give it constraints that fit it to it's spot in the view
    UIButton *button = [[UIButton alloc] init];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [[button titleLabel] setFont:font];
    return button;
}

@end