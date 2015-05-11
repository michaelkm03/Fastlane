//
//  VWebBrowserHeaderLayoutManager.m
//  victorious
//
//  Created by Patrick Lynch on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VWebBrowserHeaderLayoutManager.h"
#import "VWebBrowserHeaderViewController.h"

static const NSTimeInterval kLayoutChangeAnimationDuration  = 0.5f;
static const CGFloat kLayoutChangeAnimationSpringDampening  = 0.8f;
static const CGFloat kLayoutChangeAnimationSpringVelocity   = 0.1f;
static const CGFloat kDefaultLeadingSpace                   = 8.0f;


@interface VWebBrowserHeaderLayoutManager()

@property (nonatomic, weak, readwrite) IBOutlet VWebBrowserHeaderViewController *header;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *buttonBackWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *pageTitleLeadingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *buttonExitWidthConstraint;

// These cosntraints are strong because they are added and removed throughout the life of this view
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *progressBarTopConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *progressBarBottomConstraint;

@property (nonatomic, assign) CGFloat startingBackButtonWidth;
@property (nonatomic, assign) CGFloat startingExitButtonWidth;
@property (nonatomic, assign) CGFloat startingPageTitleLeading;

@property (nonatomic, assign, readonly) BOOL shouldHideNavigationControls;
@property (nonatomic, assign) BOOL hasSetInitialValues;

@end

@implementation VWebBrowserHeaderLayoutManager

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Set the defaults
    self.contentAlignment = VWebBrowserHeaderContentAlignmentLeft;
    self.progressBarAlignment = VWebBrowserHeaderProgressBarAlignmentBottom;
    
    [self.header.view removeConstraint:self.progressBarBottomConstraint];
    [self.header.view removeConstraint:self.progressBarTopConstraint];
}

- (void)setContentAlignment:(VWebBrowserHeaderContentAlignment)contentAlignment
{
    _contentAlignment = contentAlignment;
    [self update];
}

- (void)setProgressBarAlignment:(VWebBrowserHeaderProgressBarAlignment)progressBarAlignment
{
    _progressBarAlignment = progressBarAlignment;
    [self update];
}

- (void)updateAnimated:(BOOL)animated
{
    void (^updateBlock)() = ^void ()
    {
        [self update];
    };
    
    if ( animated )
    {
        [UIView animateWithDuration:kLayoutChangeAnimationDuration
                              delay:0.0f
             usingSpringWithDamping:kLayoutChangeAnimationSpringDampening
              initialSpringVelocity:kLayoutChangeAnimationSpringVelocity
                            options:kNilOptions
                         animations:updateBlock
                         completion:nil];
    }
    else
    {
        updateBlock();
    }
}

- (BOOL)shouldHideNavigationControls
{
    return ![self.header.stateDataSource canGoBack];
}

- (void)setInitialValues
{
    if ( self.buttonBackWidthConstraint == nil ||
         self.buttonExitWidthConstraint == nil ||
         self.pageTitleLeadingConstraint == nil )
    {
        return;
    }
    
    // Capture some initial values as configured in interface builder
    self.startingBackButtonWidth = self.buttonBackWidthConstraint.constant;
    self.startingExitButtonWidth = self.buttonExitWidthConstraint.constant;
    self.startingPageTitleLeading = self.pageTitleLeadingConstraint.constant;
    
    self.hasSetInitialValues = YES;
}

- (void)update
{
    if ( !self.hasSetInitialValues )
    {
        [self setInitialValues];
        return;
    }
    
    self.buttonBackWidthConstraint.constant = self.shouldHideNavigationControls ? 0.0f : self.startingBackButtonWidth;
    
    switch ( self.progressBarAlignment )
    {
        case VWebBrowserHeaderProgressBarAlignmentTop:
            [self.header.view removeConstraint:self.progressBarBottomConstraint];
            [self.header.view addConstraint:self.progressBarTopConstraint];
            self.progressBarTopConstraint.constant = 0.0f;
            break;
            
        case VWebBrowserHeaderProgressBarAlignmentBottom:
            [self.header.view addConstraint:self.progressBarBottomConstraint];
            [self.header.view removeConstraint:self.progressBarTopConstraint];
            self.progressBarBottomConstraint.constant = 0.0f;
            break;
    }
    
    switch ( self.contentAlignment )
    {
        case VWebBrowserHeaderContentAlignmentCenter:
            self.header.labelTitle.textAlignment = NSTextAlignmentCenter;
            self.buttonExitWidthConstraint.constant = 0.0f;
            self.pageTitleLeadingConstraint.constant = self.startingPageTitleLeading + (self.shouldHideNavigationControls ? self.startingBackButtonWidth : 0.0f);
            break;
            
        case VWebBrowserHeaderContentAlignmentLeft:
            self.header.labelTitle.textAlignment = NSTextAlignmentLeft;
            self.buttonExitWidthConstraint.constant = self.startingExitButtonWidth;
            self.pageTitleLeadingConstraint.constant = self.startingPageTitleLeading + (self.shouldHideNavigationControls ? kDefaultLeadingSpace : 0.0f);
            break;
    }
    
    [self.header.view layoutIfNeeded];
}

@end