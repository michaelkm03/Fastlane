//
//  VStreamsSubViewController.m
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VGoogleAnalyticsTracking.h"
#import "VCommentsContainerViewController.h"
#import "VCommentsTableViewController.h"
#import "VKeyboardBarViewController.h"
#import "VSequence+Fetcher.h"
#import "VUser.h"
#import "VConstants.h"
#import "VObjectManager+ContentCreation.h"
#import "UIImageView+Blurring.h"
#import "UIImage+ImageCreation.h"
#import "UIStoryboard+VMainStoryboard.h"

#import "VThemeManager.h"

#import "UIImage+ImageCreation.h"

#import "MBProgressHUD.h"

@interface VCommentsContainerViewController()   <VCommentsTableViewControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;

@end

@implementation VCommentsContainerViewController

@synthesize conversationTableViewController = _conversationTableViewController;

+ (instancetype)commentsContainerView
{
    VCommentsContainerViewController *commentsContainerViewController = (VCommentsContainerViewController *)[[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:kCommentsContainerStoryboardID];
    return commentsContainerViewController;
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    [self.backgroundImage removeFromSuperview];
    UIImageView *newBackgroundView = [[UIImageView alloc] initWithFrame:self.view.frame];
    
    UIImage *placeholderImage = [UIImage resizeableImageWithColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]];
    [newBackgroundView setExtraLightBlurredImageWithURL:[[self.sequence initialImageURLs] firstObject]
                                       placeholderImage:placeholderImage];
    
    self.backgroundImage = newBackgroundView;
    [self.view insertSubview:self.backgroundImage atIndex:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Load the image on first load
    UIImage *placeholderImage = [UIImage resizeableImageWithColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]];
    [self.backgroundImage setLightBlurredImageWithURL:[[self.sequence initialImageURLs] firstObject]
                                     placeholderImage:placeholderImage];
    
    
    [self.backButton setImage:[self.backButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.backButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    
    self.titleLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    self.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.titleLabel.text =  NSLocalizedString(@"Comments", "");
    //Need to manually add this again so it appears over everything else.
    [self.view addSubview:self.backButton];
    
    self.keyboardBarViewController.promptLabel.text = NSLocalizedString(@"LeaveAComment", @"");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UITableViewController *)conversationTableViewController
{
    if (_conversationTableViewController == nil)
    {
        VCommentsTableViewController *streamsCommentsController =
        [self.storyboard instantiateViewControllerWithIdentifier:@"comments"];
        streamsCommentsController.delegate = self;
        streamsCommentsController.sequence = self.sequence;
        _conversationTableViewController = streamsCommentsController;
    }

    return _conversationTableViewController;
}

#pragma mark - VCommentsTableViewControllerDelegate

- (void)streamsCommentsController:(VCommentsTableViewController *)viewController shouldReplyToUser:(VUser *)user
{
    self.keyboardBarViewController.textViewText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"@%@ ", user.name]];
    [self.keyboardBarViewController becomeFirstResponder];
}

#pragma mark - VKeyboardBarDelegate

- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar didComposeWithText:(NSString *)text mediaURL:(NSURL *)mediaURL
{
    if ((!text || !text.length) && (!mediaURL || !mediaURL.absoluteString.length))
    {
        return;
    }
    
    MBProgressHUD  *progressHUD =   [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHUD.labelText = NSLocalizedString(@"JustAMoment", @"");
    progressHUD.detailsLabelText = NSLocalizedString(@"PublishUpload", @"");
    
    VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        [progressHUD hide:YES];
    
        [((VCommentsTableViewController *)self.conversationTableViewController) addedNewComment:nil];
    };
    
    VFailBlock fail = ^(NSOperation *operation, NSError *error)
    {
        [progressHUD hide:YES];
    };

    [[VObjectManager sharedManager] addCommentWithText:text
                                              mediaURL:mediaURL
                                            toSequence:_sequence
                                             andParent:nil
                                          successBlock:success
                                             failBlock:fail];
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidPostComment];
}

- (IBAction)pressedBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Animations

- (void)animateInWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion
{
    __block CGFloat originalConvertationX = self.conversationTableViewController.view.frame.origin.x;
    
    CGRect viewFrame = self.conversationTableViewController.view.frame;
    self.conversationTableViewController.view.frame = CGRectMake(CGRectGetWidth(self.view.frame),
                                                                 CGRectGetMinY(viewFrame),
                                                                 CGRectGetWidth(viewFrame),
                                                                 CGRectGetHeight(viewFrame));
    
    self.keyboardBarViewController.view.alpha = 0;
    self.backButton.alpha = 0;
    self.titleLabel.alpha = 0;
    if ([self.sequence.comments count])
    {
        [UIView animateWithDuration:duration*.75f
                         animations:^
         {
             CGRect viewFrame = self.conversationTableViewController.view.frame;
             self.conversationTableViewController.view.frame = CGRectMake(originalConvertationX,
                                                                          CGRectGetMinY(viewFrame),
                                                                          CGRectGetWidth(viewFrame),
                                                                          CGRectGetHeight(viewFrame));
         }
                         completion:^(BOOL finished)
         {
             [UIView animateWithDuration:duration*.25f
                              animations:^
              {
                  self.keyboardBarViewController.view.alpha = 1;
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
             self.keyboardBarViewController.view.alpha = 1;
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
    __block CGRect frame = self.conversationTableViewController.view.frame;
    frame.origin.x = 0;
    self.conversationTableViewController.view.frame = frame;
    
    [UIView animateWithDuration:duration
                     animations:^
     {
         for (UIView *view in self.view.subviews)
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
