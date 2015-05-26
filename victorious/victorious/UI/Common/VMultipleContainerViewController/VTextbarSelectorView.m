//
//  VTextbarSelectorView.m
//  victorious
//
//  Created by Sharif Ahmed on 2/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextbarSelectorView.h"
#import "NSArray+VMap.h"
#import "VDependencyManager.h"

static CGFloat const kVBarHeight = 40.0f;
static CGFloat const kVTrackLineHeight = 1.0f;
static CGFloat const kVLineHeight = 3.0f;
static CGFloat const kVLineAnimationDuration = 0.25f;

@interface VTextbarSelectorView ()

@property (nonatomic) NSMutableArray *buttons;
@property (nonatomic) UIView *selectionLine;
@property (nonatomic) UIView *trackLine;
@property (nonatomic) NSLayoutConstraint *lineLeftConstraint;
@property (nonatomic) NSUInteger realActiveViewControllerIndex;

@end

@implementation VTextbarSelectorView

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
    [self updateLineConstraintAnimated:YES];
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

#pragma mark - display updating

- (void)updateLineConstraintAnimated:(BOOL)animated
{
    CGFloat constriantConstant = ( CGRectGetWidth(self.bounds) / self.buttons.count ) * self.activeViewControllerIndex;
    if ( animated )
    {
        [UIView animateWithDuration:kVLineAnimationDuration animations:^
         {
             self.lineLeftConstraint.constant = constriantConstant;
             [self layoutIfNeeded];
         }];
    }
    else
    {
        self.lineLeftConstraint.constant = constriantConstant;
        [self setNeedsLayout];
    }
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self makeButtonsFromCurrentViewControllers];
}

#pragma mark - view setup

- (void)makeButtonsFromCurrentViewControllers
{
    if ( CGRectEqualToRect(CGRectZero, self.bounds) )
    {
        return;
    }
    
    [self removeConstraints:self.constraints];
    [self.selectionLine removeConstraints:self.selectionLine.constraints];
    
    //Remove any existing subviews from superview
    for ( UIButton *button in self.buttons )
    {
        [button removeFromSuperview];
    }
    [self.buttons removeAllObjects];
    
    UIView *view = [[UIView alloc] init];

    view.translatesAutoresizingMaskIntoConstraints = NO;
    [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self addSubview:view];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|" options:kNilOptions metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view(barHeight)]|" options:kNilOptions metrics:@{ @"barHeight" : @(kVBarHeight)} views:views]];
    
    __weak VTextbarSelectorView *wSelf = self;
    __block UIButton *priorButton = nil;
    UIColor *buttonTextColor = self.foregroundColor;
    UIFont *buttonFont = [self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
        
        VTextbarSelectorView *sSelf = wSelf;
        if ( sSelf == nil )
        {
            return;
        }
        
        //Create a button, set it's text to the title, give it constraints that fit it to it's spot in the view
        UIButton *button = [[UIButton alloc] init];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button setTitle:viewController.navigationItem.title forState:UIControlStateNormal];
        [button setTitleColor:buttonTextColor forState:UIControlStateNormal];
        button.titleLabel.font = buttonFont;
        button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        button.tag = idx;
        [button addTarget:sSelf action:@selector(pressedHeaderButton:) forControlEvents:UIControlEventTouchUpInside];
        [sSelf addSubview:button];
        
        NSDictionary *buttonDictionary = NSDictionaryOfVariableBindings(button);
        [sSelf addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|" options:kNilOptions metrics:nil views:buttonDictionary]];
        
        if (priorButton == nil)
        {
            [sSelf addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[button]" options:kNilOptions metrics:nil views:buttonDictionary]];
        }
        else
        {
            [sSelf addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[priorButton(==button)][button]" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(button, priorButton)]];
        }
        
        if (idx == sSelf.viewControllers.count - 1)
        {
            //Last label to be created, pin it to the right side of it's superview
            [sSelf addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[button]|" options:kNilOptions metrics:nil views:buttonDictionary]];
        }
        priorButton = button;
        [sSelf.buttons addObject:button];
    }];
    
    if (self.trackLine == nil)
    {
        [self setupTrackLine];
        [self addSubview:self.trackLine];
    }
    
    views = @{ @"line" : self.trackLine };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[line(lineHeight)]" options:kNilOptions metrics:@{ @"lineHeight" : @(kVTrackLineHeight) } views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[line]|" options:kNilOptions metrics:nil views:views]];
    
    //Setting up selection line
    if ( self.selectionLine == nil )
    {
        [self setupSelectionLineWithBackgroundColor:buttonTextColor];
        [self addSubview:self.selectionLine];
    }
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-trackHeight-[line(lineHeight)]" options:kNilOptions metrics:@{ @"lineHeight" : @(kVLineHeight), @"trackHeight" : @(kVTrackLineHeight) } views:@{ @"line" : self.selectionLine }]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                    attribute:NSLayoutAttributeWidth
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.selectionLine
                                                    attribute:NSLayoutAttributeWidth
                                                   multiplier:self.viewControllers.count
                                                     constant:0.0]];
    
    self.lineLeftConstraint = [NSLayoutConstraint constraintWithItem:self.selectionLine
                                                           attribute:NSLayoutAttributeLeading
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeLeft
                                                          multiplier:1.0f
                                                            constant:0.0];
    [self addConstraint:self.lineLeftConstraint];
    
    if ( _realActiveViewControllerIndex >= self.buttons.count )
    {
        _realActiveViewControllerIndex = 0;
    }
    [self updateLineConstraintAnimated:NO];
}

- (void)setupSelectionLineWithBackgroundColor:(UIColor *)backgroundColor
{
    self.selectionLine = [[UIView alloc] init];
    self.selectionLine.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectionLine.backgroundColor = backgroundColor;
}

- (void)setupTrackLine
{
    self.trackLine = [[UIView alloc] init];
    self.trackLine.translatesAutoresizingMaskIntoConstraints = NO;
    self.trackLine.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.3];
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

@end
