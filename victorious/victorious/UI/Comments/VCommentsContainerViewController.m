//
//  VStreamsSubViewController.m
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCommentsContainerViewController.h"

#import "MBProgressHUD.h"

#import "VGoogleAnalyticsTracking.h"
#import "VCommentsTableViewController.h"
#import "VDependencyManager.h"
#import "VKeyboardBarViewController.h"
#import "VSequence+Fetcher.h"
#import "VUser.h"
#import "VConstants.h"
#import "VNavigationController.h"
#import "VObjectManager+ContentCreation.h"
#import "UIImageView+Blurring.h"
#import "UIImage+ImageCreation.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "VAuthorizedAction.h"
#import "UIImage+ImageCreation.h"

#import "VDependencyManager+VBackground.h"
#import "VBackground.h"
#import "UIView+AutoLayout.h"

static const CGFloat kNoPreviewBackgroundTransparency = 0.75f;
static NSString * const kCommentsViewControllerKey = @"commentsScreen";
static NSString * const kSequenceKey = @"sequence";

@interface VCommentsContainerViewController() <VCommentsTableViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) UIView *backgroundImage;
@property (strong, nonatomic) UIView *fallbackBackground;

@end

@implementation VCommentsContainerViewController

@synthesize conversationTableViewController = _conversationTableViewController;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VCommentsContainerViewController *viewController = (VCommentsContainerViewController *)[[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:kCommentsContainerStoryboardID];
    viewController.dependencyManager = dependencyManager;
    viewController.sequence = [dependencyManager templateValueOfType:[VSequence class] forKey:kSequenceKey];
    return viewController;
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    [self.backgroundImage removeFromSuperview];
    
    UIView *newBackgroundView;
    
    NSURL *firstPreviewURL = [[self.sequence initialImageURLs] firstObject];
    NSString *firstPreviewURLString = [firstPreviewURL absoluteString];
    
    // Check if we have a preview image to blur as the background
    if (firstPreviewURLString.length > 0)
    {
        newBackgroundView = [[UIImageView alloc] initWithFrame:self.view.frame];
        [(UIImageView *)newBackgroundView applyExtraLightBlurAndAnimateImageWithURLToVisible:firstPreviewURL];
    }
    // Add semi transparent background if we don't have a preview image
    else
    {
        newBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        newBackgroundView.backgroundColor = [UIColor whiteColor];
        newBackgroundView.alpha = kNoPreviewBackgroundTransparency;
    }
    
    self.backgroundImage = newBackgroundView;
    [self.view insertSubview:self.backgroundImage aboveSubview:self.fallbackBackground];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *viewForBackground = [[self.dependencyManager background] viewForBackground];
    [self.view addSubview:viewForBackground];
    [self.view v_addFitToParentConstraintsToSubview:viewForBackground];
    [self.view sendSubviewToBack:viewForBackground];
    self.fallbackBackground = viewForBackground;
    
    [self.backButton setImage:[self.backButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.backButton.tintColor = [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
    
    self.titleLabel.textColor = [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
    self.titleLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
    self.titleLabel.text =  NSLocalizedString(@"Comments", "");
    //Need to manually add this again so it appears over everything else.
    [self.view addSubview:self.backButton];
    
    self.keyboardBarViewController.promptLabel.text = NSLocalizedString(@"LeaveAComment", @"");
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)v_prefersNavigationBarHidden
{
    return YES;
}

- (UITableViewController *)conversationTableViewController
{
    if (_conversationTableViewController == nil)
    {
        VCommentsTableViewController *streamsCommentsController = [VCommentsTableViewController newWithDependencyManager:self.dependencyManager];
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

- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar didComposeWithText:(NSString *)text publishParameters:(VPublishParameters *)publishParameters
{
    if ((!text || !text.length) && (publishParameters == nil || !publishParameters.mediaToUploadURL.absoluteString.length))
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
                                              publishParameters:publishParameters
                                            toSequence:_sequence
                                             andParent:nil
                                          successBlock:success
                                             failBlock:fail];
}

- (BOOL)canPerformAuthorizedAction
{
    VAuthorizedAction *authorization = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                      dependencyManager:self.dependencyManager];
    return [authorization performFromViewController:self
                                            context:VAuthorizationContextAddComment
                                         completion:^(BOOL authorized){}];
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

#pragma mark -

@implementation VDependencyManager (VCommentsContainerViewController)

- (VCommentsContainerViewController *)commentsContainerWithSequence:(VSequence *)sequence
{
    NSParameterAssert(sequence != nil );
    return [self templateValueOfType:[VCommentsContainerViewController class] forKey:kCommentsViewControllerKey withAddedDependencies:@{ kSequenceKey: sequence }];
}

@end
