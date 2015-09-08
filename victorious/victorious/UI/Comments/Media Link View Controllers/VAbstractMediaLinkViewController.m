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

+ (instancetype)newWithMediaUrl:(NSURL *)url andMediaLinkType:(VCommentMediaType)linkType
{
    NSParameterAssert(url != nil);
    
    VAbstractMediaLinkViewController *linkViewController;
    switch (linkType)
    {
        case VCommentMediaTypeVideo:
            linkViewController = [[VVideoLinkViewController alloc] initWithUrl:url];
            break;
            
        case VCommentMediaTypeGIF:
            linkViewController = [[VGifLinkViewController alloc] initWithUrl:url];
            break;
            
        case VCommentMediaTypeImage:
        default:
            linkViewController = [[VImageLinkViewController alloc] initWithUrl:url];
            break;
    }
    return linkViewController;
}

- (instancetype)initWithUrl:(NSURL *)url
{
    NSParameterAssert(url != nil);
    
    self = [super initWithNibName:NSStringFromClass([VAbstractMediaLinkViewController class]) bundle:[NSBundle bundleForClass:[VAbstractMediaLinkViewController class]]];
    if ( self != nil )
    {
        _mediaUrl = url;
        _contentAspectRatio = 1.0f;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
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
