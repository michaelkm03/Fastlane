//
//  VStreamsSubViewController.m
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCommentsContainerViewController.h"
#import "VCommentsTableViewController.h"
#import "VKeyboardBarViewController.h"
#import "VSequence+Fetcher.h"
#import "VUser.h"
#import "VConstants.h"
#import "VObjectManager+Comment.h"
#import "UIView+VFrameManipulation.h"
#import "UIImageView+Blurring.h"
#import "UIImage+ImageCreation.h"

#import "VThemeManager.h"

@interface VCommentsContainerViewController()   <VCommentsTableViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton* backButton;
@property (weak, nonatomic) IBOutlet UIImageView* backgroundImage;
@property (weak, nonatomic) IBOutlet UILabel* titleLabel;

@end

@implementation VCommentsContainerViewController

@synthesize conversationTableViewController = _conversationTableViewController;

+ (instancetype)commentsContainerView
{
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VCommentsContainerViewController* commentsContainerViewController = (VCommentsContainerViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kCommentsContainerStoryboardID];

    return commentsContainerViewController;
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    UIImage* placeholderImage = [UIImage resizeableImageWithColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]];
    [self.backgroundImage setLightBlurredImageWithURL:[[self.sequence initialImageURLs] firstObject]
                                     placeholderImage:placeholderImage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Load the image on first load
    UIImage* placeholderImage = [UIImage resizeableImageWithColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]];
    [self.backgroundImage setLightBlurredImageWithURL:[[self.sequence initialImageURLs] firstObject]
                                     placeholderImage:placeholderImage];
    
    
    [self.backButton setImage:[self.backButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.backButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    
    self.titleLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    self.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading1Font];
    
    //Need to manually add this again so it appears over everything else.
    [self.view addSubview:self.backButton];
}

- (UITableViewController *)conversationTableViewController
{
    if(_conversationTableViewController == nil)
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
    self.keyboardBarViewController.textView.text = [NSString stringWithFormat:@"@%@ ", user.name];
    [self.keyboardBarViewController.textView becomeFirstResponder];
}

#pragma mark - VKeyboardBarDelegate

- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar didComposeWithText:(NSString *)text mediaURL:(NSURL *)mediaURL mediaExtension:(NSString *)mediaExtension
{
    __block UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(0, 0, 24, 24);
    indicator.hidesWhenStopped = YES;
    [self.view addSubview:indicator];
    indicator.center = self.view.center;
    [indicator startAnimating];
    
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSLog(@"%@", resultObjects);
        [indicator stopAnimating];
        [(VCommentsTableViewController*)self sortComments];
    };
    VFailBlock fail = ^(NSOperation* operation, NSError* error)
    {
        if (error.code == 5500)
        {
            NSLog(@"%@", error);
            [indicator stopAnimating];
            
            UIAlertView*    alert   =
            [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TranscodingMediaTitle", @"")
                                       message:NSLocalizedString(@"TranscodingMediaBody", @"")
                                      delegate:nil
                             cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                             otherButtonTitles:nil];
            [alert show];
        }
        [indicator stopAnimating];
    };
    
    NSData *data = [NSData dataWithContentsOfURL:mediaURL];
    [[NSFileManager defaultManager] removeItemAtURL:mediaURL error:nil];
    
    [[VObjectManager sharedManager] addCommentWithText:text
                                                  Data:data
                                        mediaExtension:mediaExtension
                                              mediaUrl:nil
                                            toSequence:_sequence
                                             andParent:nil
                                          successBlock:success
                                             failBlock:fail];
}

@end
