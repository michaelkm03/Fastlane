//
//  VAbstractMediaLinkViewController.m
//  victorious
//
//  Created by Sharif Ahmed on 7/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractMediaLinkViewController.h"
#import "VVideoLinkViewController.h"
#import "VImageLinkViewController.h"
#import "VGifLinkViewController.h"

@interface VAbstractMediaLinkViewController ()

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak, readwrite) IBOutlet UIView *contentContainerView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentAspectRatioConstraint;

@end

@implementation VAbstractMediaLinkViewController

+ (instancetype)newWithMediaUrlString:(NSString *)urlString andMediaLinkType:(VCommentMediaType)linkType
{
    NSParameterAssert(urlString != nil);
    
    VAbstractMediaLinkViewController *linkViewController;
    switch (linkType)
    {
        case VCommentMediaTypeVideo:
            linkViewController = [[VVideoLinkViewController alloc] initWithUrlString:urlString];
            break;
            
        case VCommentMediaTypeGIF:
            linkViewController = [[VGifLinkViewController alloc] initWithUrlString:urlString];
            break;
            
        case VCommentMediaTypeImage:
        default:
            linkViewController = [[VImageLinkViewController alloc] initWithUrlString:urlString];
            break;
    }
    return linkViewController;
}

- (instancetype)initWithUrlString:(NSString *)urlString
{
    self = [super initWithNibName:NSStringFromClass([VAbstractMediaLinkViewController class]) bundle:[NSBundle bundleForClass:[VAbstractMediaLinkViewController class]]];
    if ( self != nil )
    {
        _mediaUrlString = urlString;
        _contentAspectRatio = 1.0f;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.activityIndicator startAnimating];
    
    __weak VAbstractMediaLinkViewController *weakSelf = self;
    [self loadMediaWithCompletionBlock:^ (CGFloat contentAspectRatio)
    {
        __strong VAbstractMediaLinkViewController *strongSelf = weakSelf;
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

@implementation VAbstractMediaLinkViewController (SubclassOverrides)

- (void)loadMediaWithCompletionBlock:(MediaLoadingCompletionBlock)completionBlock
{
    NSAssert(false, @"Subclasses of VMediaLinkViewController must override loadMediaWithCompletionBlock:");
}

@end
