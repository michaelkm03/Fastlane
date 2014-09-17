//
//  VHashTagContainerViewController.m
//  victorious
//
//  Created by Lawrence Leach on 7/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHashTagContainerViewController.h"
#import "VHashTagStreamViewController.h"
#import "VKeyboardBarViewController.h"
#import "VSequence+Fetcher.h"
#import "VUser.h"
#import "VConstants.h"
#import "VObjectManager+ContentCreation.h"
#import "UIImageView+Blurring.h"
#import "UIImage+ImageCreation.h"
#import "VStreamContainerViewController.h"
#import "VContentViewController.h"

#import "VCommentToContentAnimator.h"
#import "VCommentToStreamAnimator.h"

#import "VThemeManager.h"

#import "UIImage+ImageCreation.h"

#import "MBProgressHUD.h"

@interface VHashTagContainerViewController () <UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton* backButton;
@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView* backgroundImage;

@end

@implementation VHashTagContainerViewController

- (id)init
{
    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    return (VHashTagContainerViewController *)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kHashTagsContainerStoryboardID];
    
}

- (void)setHashTag:(NSString *)hashTag
{
    _hashTag = hashTag;
    self.streamViewController = [[VHashTagStreamViewController alloc] initWithHashTag:hashTag];
    self.streamViewController.sequence = self.sequence;

    [self.streamViewController setHashTag:hashTag];
    self.tableViewController = self.streamViewController;
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    [self.backgroundImage removeFromSuperview];
    UIImageView* newBackgroundView = [[UIImageView alloc] initWithFrame:self.view.frame];
    
    UIImage* placeholderImage = [UIImage resizeableImageWithColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]];
    [newBackgroundView setLightBlurredImageWithURL:[[self.sequence initialImageURLs] firstObject]
                                  placeholderImage:placeholderImage];
    
    self.backgroundImage = newBackgroundView;
    [self.view insertSubview:self.backgroundImage atIndex:0];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *titleText = [NSString stringWithFormat:@"#%@", self.hashTag];
    self.headerLabel.text = NSLocalizedString(titleText, nil);
    
    [self.streamViewController setHashTag:self.hashTag];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)pressedBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - VAnimation

- (void)animateInWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion
{
    __block CGFloat originalConvertationX = self.tableViewController.view.frame.origin.x;
    
    CGRect viewFrame = self.tableViewController.view.frame;
    self.tableViewController.view.frame = CGRectMake(CGRectGetWidth(self.view.frame),
                                                                 CGRectGetMinY(viewFrame),
                                                                 CGRectGetWidth(viewFrame),
                                                                 CGRectGetHeight(viewFrame));
    
    self.backButton.alpha = 0;
    self.titleLabel.alpha = 0;
    if ([self.sequence.comments count])
    {
        [UIView animateWithDuration:duration*.75f
                         animations:^
         {
             CGRect viewFrame = self.tableViewController.view.frame;
             self.tableViewController.view.frame = CGRectMake(originalConvertationX,
                                                                          CGRectGetMinY(viewFrame),
                                                                          CGRectGetWidth(viewFrame),
                                                                          CGRectGetHeight(viewFrame));
         }
                         completion:^(BOOL finished)
         {
             [UIView animateWithDuration:duration*.25f
                              animations:^
              {
                  self.backButton.alpha = 1;
                  self.titleLabel.alpha = 1;
              }
                              completion:^(BOOL finished)
              {
                  if (completion)
                  {
                      completion(finished);
                  }
              }];
         }];
    }
    else
    {
        [UIView animateWithDuration:duration*.25f
                         animations:^
         {
             self.backButton.alpha = 1;
             self.titleLabel.alpha = 1;
         }
                         completion:^(BOOL finished)
         {
             if (completion)
             {
                 completion(finished);
             }
         }];
    }
}

- (void)animateOutWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion
{
    __block CGRect frame = self.tableViewController.view.frame;
    frame.origin.x = 0;
    self.tableViewController.view.frame = frame;
    
    [UIView animateWithDuration:.5f
                     animations:^
     {
         frame.origin.x = CGRectGetWidth(self.tableViewController.view.frame);
         self.tableViewController.view.frame = frame;
         for (UIView* view in self.view.subviews)
         {
             if ([view isKindOfClass:[UIImageView class]])
             {
                 continue;
             }
             
             if (view.center.y > self.view.center.y)
             {
                 view.center = CGPointMake(view.center.x, view.center.y + self.view.frame.size.height);
             }
             else
             {
                 view.center = CGPointMake(view.center.x, view.center.y - self.view.frame.size.height);
             }
         }
     }
                     completion:^(BOOL finished)
     {
         if (completion)
         {
             completion(finished);
         }
     }];
}

@end
