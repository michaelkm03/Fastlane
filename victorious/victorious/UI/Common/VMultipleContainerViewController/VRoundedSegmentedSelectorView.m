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

@interface VRoundedSegmentedSelectorView ()

@property (nonatomic, assign) NSUInteger realActiveViewControllerIndex;
@property (nonatomic, strong) VExtendedView *pillView;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) UIImageView *selectionView;
@property (nonatomic, strong) NSLayoutConstraint *selectionViewLeftConstraint;
@property (nonatomic, strong) UIColor *pillColor;

@property (nonatomic, strong) CAShapeLayer *maskLayer;

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
    [self makeButtonsFromCurrentViewControllers];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, kVBarHeight);
}

#pragma mark - activeViewControllerIndex updating

- (void)setActiveViewControllerIndex:(NSUInteger)activeViewControllerIndex
{
    self.realActiveViewControllerIndex = activeViewControllerIndex;
    [self updateSelectionViewConstraintAnimated:YES];
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

- (void)makeButtonsFromCurrentViewControllers
{
    if ( CGRectEqualToRect(CGRectZero, self.bounds) )
    {
        return;
    }
    
    [self removeConstraints:self.constraints];
    [self.pillView removeConstraints:self.pillView.constraints];
    
    //Remove any existing subviews from superview
    for ( UIButton *button in self.buttons )
    {
        [button removeFromSuperview];
    }
    [self.buttons removeAllObjects];
    [self.pillView removeFromSuperview];
    
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
    
    //Setup the buttons that will allow users to select different streams
    __weak VRoundedSegmentedSelectorView *wSelf = self;
    __block UIButton *priorButton = nil;
    CGFloat cornerRadius = self.pillView.cornerRadius;
    UIColor *buttonSelectionColor = [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    NSDictionary *buttonHorizontalInsetMetrics = @{ @"inset" : @(cornerRadius) };
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
        
        VRoundedSegmentedSelectorView *sSelf = wSelf;
        if ( sSelf == nil )
        {
            return;
        }
        
        //Note: Setting the button's text color to the "highlighted" color here so that it appears that way in the snapshot below
        UIButton *button = [self newButtonWithCornerRadius:cornerRadius title:viewController.title font:[self.dependencyManager fontForKey:VDependencyManagerHeading3FontKey] andTextColor:buttonSelectionColor];
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
    
    //Now add the selectionView which will show which tab is selected. This must be done after the snapshot otherwise it will appear in the snapshot.
    [self.pillView addSubview:self.selectionView];
    NSDictionary *selectionViews = @{ @"selectionView" : self.selectionView };
    [self.pillView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[selectionView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:selectionViews]];
    CGFloat selectionViewWidth = ( ( CGRectGetWidth(self.bounds) - kVHorizontalInset * 2 - cornerRadius * 2 ) / self.viewControllers.count ) + cornerRadius * 2;
    [self.selectionView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionView
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0f
                                                                    constant:selectionViewWidth]];
    self.selectionViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.selectionView
                                                                    attribute:NSLayoutAttributeLeft
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.pillView
                                                                    attribute:NSLayoutAttributeLeft
                                                                   multiplier:1.0f
                                                                     constant:0.0f];
    [self.pillView addConstraint:self.selectionViewLeftConstraint];
    [self.selectionView layoutIfNeeded];
    
    //Reset buttons to proper "unhighlighted" color
    for (UIButton *button in self.buttons)
    {
        [button setTitleColor:self.pillColor forState:UIControlStateNormal];
        [[button titleLabel] setFont:[self.dependencyManager fontForKey:VDependencyManagerHeading4FontKey]];
    }
    
    //Add the snapshot imageview to our bar
    UIImageView *highlightOverView = [[UIImageView alloc] initWithImage:barScreenShot];
    [self.pillView addSubview:highlightOverView];
    [self.pillView v_addFitToParentConstraintsToSubview:highlightOverView];
    
    //Create the mask layer that will mask the snapshot of the highlighted text
    self.maskLayer = [[CAShapeLayer alloc] init];
    CGRect maskRect = self.selectionView.bounds;
    self.maskLayer.cornerRadius = cornerRadius;
    CGPathRef path = CGPathCreateWithRect(maskRect, NULL);
    self.maskLayer.path = path;
    CGPathRelease(path);
    highlightOverView.layer.mask = self.maskLayer;
    
    if ( _realActiveViewControllerIndex >= self.buttons.count )
    {
        _realActiveViewControllerIndex = 0;
    }
    [self updateSelectionViewConstraintAnimated:NO];
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

#pragma mark - display updating

- (void)updateSelectionViewConstraintAnimated:(BOOL)animated
{
    UIButton *anyButton = self.buttons.firstObject;
    if ( anyButton != nil )
    {
        CGFloat constriantConstant = ( CGRectGetWidth(anyButton.bounds) ) * self.activeViewControllerIndex;
        CGRect targetMaskFrame = self.selectionView.frame;
        targetMaskFrame.origin.x = constriantConstant;
        CGPathRef targetPath = CGPathCreateWithRect(targetMaskFrame, NULL);
        if ( animated )
        {
            targetMaskFrame.origin.x = CGRectGetMinX(((CALayer *)self.selectionView.layer.presentationLayer).frame);
            CGPathRef startPath = CGPathCreateWithRect(targetMaskFrame, NULL);
            [self.selectionView.layer removeAllAnimations];
            self.selectionViewLeftConstraint.constant = CGRectGetMinX(targetMaskFrame);
            [self.selectionView layoutIfNeeded];
            [UIView animateWithDuration:kVSelectionAnimationDuration
                             animations:^
             {
                 self.selectionViewLeftConstraint.constant = constriantConstant;
                [self layoutIfNeeded];
             }];
            
            CABasicAnimation *a = [CABasicAnimation animationWithKeyPath:@"path"];
            [a setDuration:kVSelectionAnimationDuration];
            [a setFromValue:(__bridge id)startPath];
            [a setToValue:(__bridge id)targetPath];
            [a setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            self.maskLayer.path = targetPath;
            [self.maskLayer addAnimation:a forKey:@"path"];
            CGPathRelease(targetPath);
            CGPathRelease(startPath);

        }
        else
        {
            self.selectionViewLeftConstraint.constant = constriantConstant;
            self.maskLayer.path = targetPath;
            [self setNeedsLayout];
            CGPathRelease(targetPath);
        }
    }
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self makeButtonsFromCurrentViewControllers];
}

- (UIButton *)newButtonWithCornerRadius:(CGFloat)cornerRadius title:(NSString *)title font:(UIFont *)font andTextColor:(UIColor *)color
{
    //Create a label, set it's text to the title, give it constraints that fit it to it's spot in the view
    UIButton *button = [[UIButton alloc] init];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    button.imageView.layer.cornerRadius = cornerRadius;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [[button titleLabel] setFont:font];
    [button setTitleColor:color forState:UIControlStateHighlighted];
    return button;
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
    _pillColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
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

- (UIImageView *)selectionView
{
    if ( _selectionView )
    {
        return _selectionView;
    }
    
    _selectionView = [[UIImageView alloc] initWithImage:[UIImage resizeableImageWithColor:self.pillColor]];
    _selectionView.clipsToBounds = YES;
    _selectionView.backgroundColor = [UIColor blackColor];
    _selectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _selectionView.layer.cornerRadius = self.pillView.cornerRadius;
    return _selectionView;
}

@end
