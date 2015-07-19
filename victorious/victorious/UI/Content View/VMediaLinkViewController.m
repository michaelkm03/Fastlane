//
//  VMediaLinkViewController.m
//  victorious
//
//  Created by Sharif Ahmed on 7/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VMediaLinkViewController.h"
#import "VVideoLinkViewController.h"
#import "VImageLinkViewController.h"
#import "VGifLinkViewController.h"

@interface VMediaLinkViewController ()

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak, readwrite) IBOutlet UIView *contentContainerView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentAspectRatioConstraint;

@end

@implementation VMediaLinkViewController

+ (instancetype)newWithMediaUrlString:(NSString *)urlString andMediaLinkType:(VInStreamMediaLinkType)linkType
{
    NSParameterAssert(urlString != nil);
    
    VMediaLinkViewController *linkViewController;
    switch (linkType)
    {
        case VInStreamMediaLinkTypeVideo:
            return [[VVideoLinkViewController alloc] initWithUrlString:urlString];
            break;
            
        case VInStreamMediaLinkTypeGif:
            return [[VGifLinkViewController alloc] initWithUrlString:urlString];
            break;
            
            
        case VInStreamMediaLinkTypeImage:
        default:
            return [[VImageLinkViewController alloc] initWithUrlString:urlString];
            break;
    }
    return linkViewController;
}

- (instancetype)initWithUrlString:(NSString *)urlString
{
    self = [super initWithNibName:NSStringFromClass([VMediaLinkViewController class]) bundle:nil];
    if ( self != nil )
    {
        _mediaUrlString = urlString;
        _contentAspectRatio = 1;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.activityIndicator startAnimating];
    
    __weak VMediaLinkViewController *weakSelf = self;
    [self loadMediaWithCompletionBlock:^ (CGFloat contentAspectRatio)
    {
        __strong VMediaLinkViewController *strongSelf = weakSelf;
        if ( strongSelf == nil )
        {
            return;
        }
        
        [strongSelf.activityIndicator stopAnimating];
        strongSelf.contentAspectRatio = contentAspectRatio;
    }];
}

- (void)updateViewConstraints
{
    if ( self.contentAspectRatio != self.contentAspectRatioConstraint.constant )
    {
        [self.contentContainerView removeConstraint:self.contentAspectRatioConstraint];
        NSLayoutConstraint *newRatioConstraint = [NSLayoutConstraint constraintWithItem:self.contentContainerView
                                                                              attribute:NSLayoutAttributeWidth
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.contentContainerView
                                                                              attribute:NSLayoutAttributeHeight
                                                                             multiplier:self.contentAspectRatio
                                                                               constant:0.0f];
        self.contentAspectRatioConstraint = newRatioConstraint;
        [self.contentContainerView addConstraint:self.contentAspectRatioConstraint];
    }
    
    [super updateViewConstraints];
}

- (void)setContentAspectRatio:(CGFloat)contentAspectRatio
{
    _contentAspectRatio = contentAspectRatio;
    [self.view setNeedsUpdateConstraints];
}

- (IBAction)closeButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end

@implementation VMediaLinkViewController (SubclassOverrides)

- (void)loadMediaWithCompletionBlock:(MediaLoadingCompletionBlock)completionBlock
{
    NSAssert(false, @"Subclasses of VMediaLinkViewController must override loadMediaWithCompletionBlock:");
}

@end
