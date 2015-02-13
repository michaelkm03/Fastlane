//
//  VTextbarSelectorView.m
//  victorious
//
//  Created by Sharif Ahmed on 2/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextbarSelectorView.h"
#import "VDependencyManager.h"
#import "NSArray+VMap.h"

static CGFloat const kVBarHeight = 40;
static CGFloat const kVLineHeight = 1;

@interface VTextbarSelectorView ()

@property (nonatomic) NSMutableArray *buttons;
@property (nonatomic) UIView *line;
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

#pragma mark - activeViewControllerIndex updating

- (void)setActiveViewControllerIndex:(NSUInteger)activeViewControllerIndex
{
    self.realActiveViewControllerIndex = activeViewControllerIndex;
    [self updateLineConstraint];
}

//Must implement, otherwise NSNotFound is returned
- (NSUInteger)activeViewControllerIndex
{
    return self.realActiveViewControllerIndex;
}

- (void)pressedHeaderButton:(UIButton *)button
{
    [self setActiveViewControllerIndex:button.tag];
    
    if ( [self.delegate respondsToSelector:@selector(viewSelector:didSelectViewControllerAtIndex:)] )
    {
        [self.delegate viewSelector:self didSelectViewControllerAtIndex:self.realActiveViewControllerIndex];
    }
}

#pragma mark - display updating

- (void)updateLineConstraint
{
    CGFloat constriantConstant = ( CGRectGetWidth(self.bounds) / self.buttons.count ) * self.activeViewControllerIndex;
    self.lineLeftConstraint.constant = constriantConstant;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self updateLineConstraint];
}

#pragma mark - view setup

- (void)makeButtonsFromCurrentViewControllers
{
    //Remove any existing subviews from superview
    for ( UIButton *button in self.buttons )
    {
        [button removeFromSuperview];
    }
    
    UIView *view = [[UIView alloc] init];

    view.translatesAutoresizingMaskIntoConstraints = NO;
    [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self addSubview:view];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view(barHeight)]|" options:0 metrics:@{@"barHeight":@(kVBarHeight)} views:views]];
    
    __weak VTextbarSelectorView *wSelf = self;
    __block UIButton *priorButton = nil;
    UIColor *buttonTextColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    UIFont *buttonFont = [UIFont boldSystemFontOfSize:16];
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
        
        VTextbarSelectorView *sSelf = wSelf;
        if ( sSelf == nil )
        {
            return;
        }
        
        //Create a label, set it's text to the title, give it constraints that fit it to it's spot in the view
        UIButton *button = [[UIButton alloc] init];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [button setTitle:viewController.title forState:UIControlStateNormal];
        [button setTitleColor:buttonTextColor forState:UIControlStateNormal];
        [[button titleLabel] setFont:buttonFont];
        button.tag = idx;
        [button addTarget:sSelf action:@selector(pressedHeaderButton:) forControlEvents:UIControlEventTouchUpInside];
        [sSelf addSubview:button];
        
        NSDictionary *buttonDictionary = NSDictionaryOfVariableBindings(button);
        [sSelf addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|" options:0 metrics:nil views:buttonDictionary]];
        
        if ( !priorButton )
        {
            [sSelf addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[button]" options:0 metrics:nil views:buttonDictionary]];
        }
        else
        {
            [sSelf addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[priorButton(==button)][button]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(button, priorButton)]];
        }
        
        if ( idx == sSelf.viewControllers.count - 1 )
        {
            //Last label to be created, pin it to the right side of it's superview
            [sSelf addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[button]|" options:0 metrics:nil views:buttonDictionary]];
        }
        priorButton = button;
        [sSelf.buttons addObject:button];
        
    }];
    
    if ( self.line == nil )
    {
        self.line = [[UIView alloc] init];
        self.line.translatesAutoresizingMaskIntoConstraints = NO;
        self.line.backgroundColor = buttonTextColor;
        [self addSubview:self.line];
    }
    else
    {
        [self.line removeConstraints:self.line.constraints];
    }
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[line(lineHeight)]" options:0 metrics:@{ @"lineHeight" : @(kVLineHeight) } views:@{ @"line" : self.line }]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                    attribute:NSLayoutAttributeWidth
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.line
                                                    attribute:NSLayoutAttributeWidth
                                                   multiplier:self.viewControllers.count
                                                     constant:0.0]];
    
    self.lineLeftConstraint = [NSLayoutConstraint constraintWithItem:self.line
                                                           attribute:NSLayoutAttributeLeading
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeLeft
                                                          multiplier:1.0f
                                                            constant:0.0];
    [self addConstraint:self.lineLeftConstraint];
    
    _realActiveViewControllerIndex = 0;
}

#pragma mark - lazy inits

- (NSMutableArray *)buttons
{
    if ( _buttons )
    {
        return _buttons;
    }

    _buttons = [[NSMutableArray alloc] init];
    return _buttons;
}

@end
