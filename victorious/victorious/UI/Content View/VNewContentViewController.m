//
//  VNewContentViewController.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNewContentViewController.h"

// Theme
#import "VThemeManager.h"

// SubViews
#import "VExperienceEnhancerBar.h"

// View Categories
#import "UIView+VShadows.h"
#import "UIActionSheet+VBlocks.h"

// Images
#import "UIImage+ImageCreation.h"
#import "UIImageView+Blurring.h"

// Layout
#import "VShrinkingContentLayout.h"

// Cells
#import "VContentCell.h"
#import "VContentVideoCell.h"
#import "VContentImageCell.h"
#import "VTickerCell.h"
#import "VContentCommentsCell.h"

// Supplementary Views
#import "VSectionHandleReusableView.h"
#import "VContentBackgroundSupplementaryView.h"

// Input Acceossry
#import "VKeyboardInputAccessoryView.h"

// ViewControllers
#import "VCameraViewController.h"
#import "VVideoLightboxViewController.h"
#import "VImageLightboxViewController.h"
#import "VActionSheetViewController.h"
#import "VActionSheetTransitioningDelegate.h"
#import "VCameraPublishViewController.h"
#import "VRemixSelectViewController.h"
#import "VUserProfileViewController.h"
#import "VStreamContainerViewController.h"
#import "VReposterTableViewController.h"

//TODO: abstract this out of VC
#import "VStream.h"
#import "VStream+Fetcher.h"
#import "VObjectManager+Sequence.h"

// Analytics
#import "VAnalyticsRecorder.h"

// Activities
#import "VFacebookActivity.h"

// Transitioning
#import "VLightboxTransitioningDelegate.h"
#import "VActionSheetPresentationAnimator.h"

// Logged in
#import "VObjectManager+Login.h"
#import "VLoginViewController.h"

// Formatters
#import "VElapsedTimeFormatter.h"

@interface VNewContentViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate,VKeyboardInputAccessoryViewDelegate,VContentVideoCellDelgetate>

@property (nonatomic, strong, readwrite) VContentViewViewModel *viewModel;
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, assign) BOOL hasAutoPlayed;
@property (nonatomic, strong) NSValue *videoSizeValue;

@property (nonatomic, weak) IBOutlet UICollectionView *contentCollectionView;
@property (nonatomic, weak) IBOutlet UIImageView *blurredBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

// Cells
@property (nonatomic, weak) VContentCell *contentCell;
@property (nonatomic, weak) VContentVideoCell *videoCell;
@property (nonatomic, weak) VTickerCell *tickerCell;
@property (nonatomic, weak) VSectionHandleReusableView *handleView;

// Experience Enhancers
@property (nonatomic, weak) VExperienceEnhancerBar *experienceEnhancerBar;
@property (nonatomic, weak) VKeyboardInputAccessoryView *textEntryView;

@property (nonatomic, strong) VElapsedTimeFormatter *elapsedTimeFormatter;

// Constraints
@property (nonatomic, weak) NSLayoutConstraint *bottomExperienceEnhancerBarToContainerConstraint;
@property (nonatomic, weak) NSLayoutConstraint *bottomKeyboardToContainerBottomConstraint;
@property (nonatomic, weak) NSLayoutConstraint *keyboardInputBarHeightConstraint;

@end

@implementation VNewContentViewController

#pragma mark - Factory Methods

+ (VNewContentViewController *)contentViewControllerWithViewModel:(VContentViewViewModel *)viewModel
{
    VNewContentViewController *contentViewController = [[UIStoryboard storyboardWithName:@"ContentView" bundle:nil] instantiateInitialViewController];
    
    contentViewController.viewModel = viewModel;
    contentViewController.hasAutoPlayed = NO;
    contentViewController.elapsedTimeFormatter = [[VElapsedTimeFormatter alloc] init];
    contentViewController.videoSizeValue = nil;
    
    return contentViewController;
}

#pragma mark - Dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIResponder

- (UIView *)inputAccessoryView
{
    VInputAccessoryView *_inputAccessoryView = nil;
    if (_inputAccessoryView)
    {
        return _inputAccessoryView;
    }
    
    _inputAccessoryView = [VInputAccessoryView new];
    
    return _inputAccessoryView;
}

#pragma mark - UIViewController

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.contentCollectionView.collectionViewLayout = [[VShrinkingContentLayout alloc] init];
    
    [self.closeButton setImage:[self.closeButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                      forState:UIControlStateNormal];
    self.closeButton.tintColor = [UIColor whiteColor];
    [self.closeButton v_applyShadowsWithZIndex:2];
    
    [self.moreButton setImage:[self.moreButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                     forState:UIControlStateNormal];
    self.moreButton.imageView.tintColor = [UIColor whiteColor];
    [self.moreButton v_applyShadowsWithZIndex:2];
    
    VKeyboardInputAccessoryView *inputAccessoryView = [VKeyboardInputAccessoryView defaultInputAccessoryView];
    inputAccessoryView.translatesAutoresizingMaskIntoConstraints = NO;
    inputAccessoryView.returnKeyType = UIReturnKeyDone;
    inputAccessoryView.delegate = self;
    self.textEntryView = inputAccessoryView;
    NSLayoutConstraint *inputViewLeadingConstraint = [NSLayoutConstraint constraintWithItem:inputAccessoryView
                                                                                  attribute:NSLayoutAttributeLeading
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self.view
                                                                                  attribute:NSLayoutAttributeLeading
                                                                                 multiplier:1.0f
                                                                                   constant:0.0f];
    NSLayoutConstraint *inputViewTrailingconstraint = [NSLayoutConstraint constraintWithItem:inputAccessoryView
                                                                                   attribute:NSLayoutAttributeTrailing
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self.view
                                                                                   attribute:NSLayoutAttributeTrailing
                                                                                  multiplier:1.0f
                                                                                    constant:0.0f];
    self.keyboardInputBarHeightConstraint = [NSLayoutConstraint constraintWithItem:inputAccessoryView
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1.0f
                                                                          constant:VInputAccessoryViewDesiredMinimumHeight];
    self.bottomKeyboardToContainerBottomConstraint = [NSLayoutConstraint constraintWithItem:inputAccessoryView
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self.view
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                 multiplier:1.0f
                                                                                   constant:0.0f];
    self.bottomKeyboardToContainerBottomConstraint.priority = UILayoutPriorityDefaultLow;
    [self.view addSubview:inputAccessoryView];
    [self.view addConstraints:@[self.keyboardInputBarHeightConstraint, inputViewLeadingConstraint, inputViewTrailingconstraint, self.bottomKeyboardToContainerBottomConstraint]];
    
    VExperienceEnhancerBar *experienceEnhancerBar = [VExperienceEnhancerBar experienceEnhancerBar];
    experienceEnhancerBar.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:experienceEnhancerBar
                                                                         attribute:NSLayoutAttributeLeading
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeLeading
                                                                        multiplier:1.0f
                                                                          constant:0.0f];
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:experienceEnhancerBar
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.view
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1.0f
                                                                           constant:0.0f];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:experienceEnhancerBar
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0f
                                                                         constant:VExperienceEnhancerDesiredMinimumHeight];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:experienceEnhancerBar
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0f
                                                                         constant:0.0f];
    self.bottomExperienceEnhancerBarToContainerConstraint = bottomConstraint;
    [self.view addSubview:experienceEnhancerBar];
    [self.view addConstraints:@[leadingConstraint, trailingConstraint, heightConstraint, bottomConstraint]];
    inputAccessoryView.maximumAllowedSize = CGSizeMake(CGRectGetWidth(self.view.bounds), 70.0f); // This is somewhat arbitrary to prevent the input accessory view from growing too much.
    
    self.experienceEnhancerBar = experienceEnhancerBar;
    self.experienceEnhancerBar.pressedTextEntryHandler = ^void()
    {
        [self.textEntryView startEditing];
    };
    
    VExperienceEnhancer *baconEnhancer = [[VExperienceEnhancer alloc] init];
    baconEnhancer.icon = [UIImage imageNamed:@"eb_bacon"];
    baconEnhancer.labelText = @"123";
    baconEnhancer.selectionBlock = ^(void)
    {
        NSMutableArray *animationImages = [NSMutableArray new];
        for (int i = 1; i <= 6; i++)
        {
            NSString *animationName = [NSString stringWithFormat:@"tumblr_mkyb94qEFr1s5jjtzo1_400-%i (dragged)", i];
            [animationImages addObject:[UIImage imageNamed:animationName]];
        }
        
        self.contentCell.animationDuration = 0.75f;
        self.contentCell.animationSequence = animationImages;
        [self.contentCell playAnimation];
    };

    VExperienceEnhancer *fireworkEnhancer = [[VExperienceEnhancer alloc] init];
    fireworkEnhancer.icon = [UIImage imageNamed:@"eb_firework"];
    fireworkEnhancer.labelText = @"143";
    
    VExperienceEnhancer *thumbsUpEnhancer = [[VExperienceEnhancer alloc] init];
    thumbsUpEnhancer.icon = [UIImage imageNamed:@"eb_thumbsup"];
    thumbsUpEnhancer.labelText = @"321";
    
    VExperienceEnhancer *tongueEnhancer = [[VExperienceEnhancer alloc] init];
    tongueEnhancer.icon = [UIImage imageNamed:@"eb_tongueout"];
    tongueEnhancer.labelText = @"555";
    
    VExperienceEnhancer *winEnhancer = [[VExperienceEnhancer alloc] init];
    winEnhancer.icon = [UIImage imageNamed:@"eb_win"];
    winEnhancer.labelText = @"999";
    
    VExperienceEnhancer *tomatoEnhancer = [[VExperienceEnhancer alloc] init];
    tomatoEnhancer.icon = [UIImage imageNamed:@"Tomato"];
    tomatoEnhancer.labelText = @"1";
    tomatoEnhancer.selectionBlock = ^(void)
    {
        NSMutableArray *tomatoSequence = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < 17; i++)
        {
            NSString *tomatoImage = [NSString stringWithFormat:@"Tomato%li", (long)i];
            [tomatoSequence addObject:[[UIImage imageNamed:tomatoImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        }
        
        UIImageView *tomatoAnimation = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        tomatoAnimation.tintColor = [UIColor redColor];
        tomatoAnimation.image = [UIImage imageNamed:@"Tomato0"];
        tomatoAnimation.animationImages = tomatoSequence;
        tomatoAnimation.animationDuration = 1.0f;
        tomatoAnimation.animationRepeatCount = 1.0f;
        tomatoAnimation.center = [self.view convertPoint:self.experienceEnhancerBar.center fromView:self.experienceEnhancerBar];
        [self.view addSubview:tomatoAnimation];
        [UIView animateWithDuration:1.5f
                         animations:^
         {

             CGPoint contentCenter = [self.view convertPoint:self.contentCell.center fromView:self.contentCell];
             tomatoAnimation.center = contentCenter;
         }
         completion:^(BOOL finished)
        {
             [tomatoAnimation startAnimating];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
            {
                [tomatoAnimation removeFromSuperview];
            });

         }];
    };
    
    self.experienceEnhancerBar.actionItems = @[baconEnhancer, tomatoEnhancer, fireworkEnhancer, thumbsUpEnhancer, tongueEnhancer, winEnhancer];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commentsDidUpdate:)
                                                 name:VContentViewViewModelDidUpdateCommentsNotification
                                               object:self.viewModel];
    
    self.contentCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    // Register nibs
    [self.contentCollectionView registerNib:[VContentCell nibForCell]
                 forCellWithReuseIdentifier:[VContentCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VContentVideoCell nibForCell]
                 forCellWithReuseIdentifier:[VContentVideoCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VContentImageCell nibForCell]
                 forCellWithReuseIdentifier:[VContentImageCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VTickerCell  nibForCell]
                 forCellWithReuseIdentifier:[VTickerCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VContentCommentsCell nibForCell]
                 forCellWithReuseIdentifier:[VContentCommentsCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VSectionHandleReusableView nibForCell]
                 forSupplementaryViewOfKind:VShrinkingContentLayoutAllCommentsHandle
                        withReuseIdentifier:[VSectionHandleReusableView suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VContentBackgroundSupplementaryView nibForCell]
                 forSupplementaryViewOfKind:VShrinkingContentLayoutContentBackgroundView
                        withReuseIdentifier:[VContentBackgroundSupplementaryView suggestedReuseIdentifier]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:VInputAccessoryViewKeyboardFrameDidChangeNotification
                                               object:nil];
    
    [self.navigationController setNavigationBarHidden:YES
                                             animated:YES];
    
    self.contentCollectionView.delegate = self;
    
    [self.viewModel fetchComments];
    
    
    self.contentCollectionView.contentInset = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.textEntryView.bounds), 0);
    self.contentCollectionView.scrollIndicatorInsets = UIEdgeInsetsMake(VShrinkingContentLayoutMinimumContentHeight,
                                                                        0,
                                                                        CGRectGetHeight(self.textEntryView.bounds), 0);
    
    UIImage *placeholderImage = [UIImage resizeableImageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];
    [self.blurredBackgroundImageView setBlurredImageWithURL:self.viewModel.imageURLRequest.URL
                                           placeholderImage:placeholderImage
                                                  tintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];

    if (self.viewModel.type == VContentViewTypeVideo)
    {
        self.textEntryView.placeholderText = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LeaveACommentAt", @""), [self.elapsedTimeFormatter stringForCMTime:self.videoCell.videoPlayerViewController.currentTime]];
    }
    else
    {
        self.textEntryView.placeholderText = NSLocalizedString(@"LaveAComment", @"");
    }
    
    self.inputAccessoryView.alpha = 0.0f;
    [UIView animateWithDuration:0.2f
                     animations:^
     {
         self.inputAccessoryView.alpha = 1.0f;
     }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.hasAutoPlayed)
    {
        [self.videoCell play];
        self.hasAutoPlayed = YES;
    }

    [self.contentCollectionView flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.contentCollectionView.delegate = nil;
    
    [self.view.superview endEditing:YES];
    
    [UIView animateWithDuration:0.2f
                     animations:^
     {
         self.inputAccessoryView.alpha = 0.0f;
     }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.inputAccessoryView removeFromSuperview];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Notification Handlers

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
 
    if ([notification.name isEqualToString:VInputAccessoryViewKeyboardFrameDidChangeNotification])
    {
        CGFloat newBottomKeyboardBarToContainerConstraintHeight = 0.0f;
        if (!isnan(endFrame.origin.y) && !isinf(endFrame.origin.y))
        {
            newBottomKeyboardBarToContainerConstraintHeight = -CGRectGetHeight([UIScreen mainScreen].bounds) + endFrame.origin.y;// + offset;
        }
        
        self.bottomKeyboardToContainerBottomConstraint.constant = newBottomKeyboardBarToContainerConstraintHeight;
        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:0.2f
                              delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^
        {
#warning There are some ugly UI bugs when the user is scrolled to the bottom and then dismisses the keyboard. This will be fixed when moving the content out of the collectionview.
            VShrinkingContentLayout *layout = (VShrinkingContentLayout *)self.contentCollectionView.collectionViewLayout;
            layout.contentInsets = UIEdgeInsetsMake(0, 0, -newBottomKeyboardBarToContainerConstraintHeight, 0);
            [self.contentCollectionView.collectionViewLayout invalidateLayout];
        }
                         completion:nil];
    }
}

- (void)commentsDidUpdate:(NSNotification *)notification
{
    if (self.viewModel.commentCount > 0)
    {
        NSIndexSet *commentsIndexSet = [NSIndexSet indexSetWithIndex:VContentViewSectionAllComments];
        [self.contentCollectionView reloadSections:commentsIndexSet];
        
        self.handleView.numberOfComments = self.viewModel.commentCount;
    }
}

#pragma mark - IBActions

- (IBAction)pressedClose:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (IBAction)pressedMore:(id)sender
{
    VActionSheetViewController *actionSheetViewController = [VActionSheetViewController actionSheetViewController];
    [VActionSheetTransitioningDelegate addNewTransitioningDelegateToActionSheetController:actionSheetViewController];
    
    VActionItem *userItem = [VActionItem userActionItemUserWithTitle:self.viewModel.authorName
                                                           avatarURL:self.viewModel.avatarForAuthor
                                                          detailText:self.viewModel.authorCaption];
    userItem.selectionHandler = ^(void)
    {
        [self dismissViewControllerAnimated:YES
                                 completion:^
         {
             VUserProfileViewController *profileViewController = [VUserProfileViewController userProfileWithUser:self.viewModel.user];
             [self.navigationController pushViewController:profileViewController animated:YES];
         }];
    };
    VActionItem *descripTionItem = [VActionItem descriptionActionItemWithText:self.viewModel.name
                                                      hashTagSelectionHandler:^(NSString *hashTag)
                                    {
                                        VStreamContainerViewController *container = [VStreamContainerViewController modalContainerForStreamTable:[VStreamTableViewController hashtagStreamWithHashtag:hashTag]];
                                        container.shouldShowHeaderLogo = NO;
                                        
                                        [self dismissViewControllerAnimated:YES
                                                                 completion:^
                                         {
                                             [self.navigationController pushViewController:container
                                                                                  animated:YES];
                                         }];
                                    }];
    VActionItem *remixItem = [VActionItem defaultActionItemWithTitle:NSLocalizedString(@"Remix", @"")
                                                          actionIcon:[UIImage imageNamed:@"icon_remix"]
                                                          detailText:self.viewModel.remixCountText];
    remixItem.selectionHandler = ^(void)
    {
        if (![VObjectManager sharedManager].mainUser)
        {
            [self dismissViewControllerAnimated:YES
                                     completion:^
             {
                 [self presentViewController:[VLoginViewController loginViewController]
                                    animated:YES
                                  completion:NULL];
             }];

            return;
        }
        
        NSString *label = [self.viewModel.sequence.remoteId stringByAppendingPathComponent:self.viewModel.sequence.name];
        [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryNavigation action:@"Pressed Remix" label:label value:nil];
        
        if (self.viewModel.type == VContentViewTypeVideo)
        {
            UIViewController *remixVC = [VRemixSelectViewController remixViewControllerWithURL:self.viewModel.sourceURLForCurrentAssetData
                                                                                    sequenceID:[self.viewModel.sequence.remoteId integerValue]
                                                                                        nodeID:self.viewModel.nodeID];
            [self presentViewController:remixVC
                               animated:YES
                             completion:
             ^{
                 [self.videoCell.videoPlayerViewController.player pause];
             }];
        }
        else
        {
            VCameraPublishViewController *publishViewController = [VCameraPublishViewController cameraPublishViewController];
            publishViewController.previewImage = self.blurredBackgroundImageView.downloadedImage;
            publishViewController.parentID = [self.viewModel.sequence.remoteId integerValue];
            publishViewController.completion = ^(BOOL complete)
            {
                [self dismissViewControllerAnimated:YES
                                         completion:nil];
            };
            UINavigationController *remixNav = [[UINavigationController alloc] initWithRootViewController:publishViewController];
            
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                            cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
                                                               onCancelButton:nil
                                                       destructiveButtonTitle:nil
                                                          onDestructiveButton:nil
                                                   otherButtonTitlesAndBlocks:NSLocalizedString(@"Meme", nil),  ^(void)
                                          {
                                              publishViewController.captionType = VCaptionTypeMeme;
                                              
                                              NSData *filteredImageData = UIImageJPEGRepresentation(self.blurredBackgroundImageView.downloadedImage, VConstantJPEGCompressionQuality);
                                              NSURL *tempDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
                                              NSURL *tempFile = [[tempDirectory URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:VConstantMediaExtensionJPG];
                                              if ([filteredImageData writeToURL:tempFile atomically:NO])
                                              {
                                                  publishViewController.mediaURL = tempFile;
                                                  [self presentViewController:remixNav
                                                                     animated:YES
                                                                   completion:nil];
                                              }
                                          },
                                          NSLocalizedString(@"Quote", nil),  ^(void)
                                          {
                                              publishViewController.captionType = VCaptionTypeQuote;
                                              
                                              NSData *filteredImageData = UIImageJPEGRepresentation(self.blurredBackgroundImageView.downloadedImage, VConstantJPEGCompressionQuality);
                                              NSURL *tempDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
                                              NSURL *tempFile = [[tempDirectory URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:VConstantMediaExtensionJPG];
                                              if ([filteredImageData writeToURL:tempFile atomically:NO])
                                              {
                                                  publishViewController.mediaURL = tempFile;
                                                  [self presentViewController:remixNav
                                                                     animated:YES
                                                                   completion:nil];
                                              }
                                          }, nil];
            [self dismissViewControllerAnimated:YES
                                     completion:^
             {
                 [actionSheet showInView:self.view];
             }];

        }
    };
    remixItem.detailSelectionHandler = ^(void)
    {
        [self dismissViewControllerAnimated:YES
                                 completion:^
         {
             VStream *stream = [VStream remixStreamForSequence:self.viewModel.sequence];
             VStreamTableViewController  *streamTableView = [VStreamTableViewController streamWithDefaultStream:stream name:@"remix" title:NSLocalizedString(@"Remixes", nil)];
             streamTableView.noContentTitle = NSLocalizedString(@"NoRemixersTitle", @"");
             streamTableView.noContentMessage = NSLocalizedString(@"NoRemixersMessage", @"");
             streamTableView.noContentImage = [UIImage imageNamed:@"noRemixIcon"];
             [self.navigationController pushViewController:[VStreamContainerViewController modalContainerForStreamTable:streamTableView] animated:YES];
             
         }];
    };
    NSString *localizedRepostRepostedText = self.viewModel.hasReposted ? NSLocalizedString(@"Reposted", @"") : NSLocalizedString(@"Repost", @"");
    VActionItem *repostItem = [VActionItem defaultActionItemWithTitle:localizedRepostRepostedText
                                                           actionIcon:[UIImage imageNamed:@"icon_repost"]
                                                           detailText:self.viewModel.repostCountText
                                                              enabled:self.viewModel.hasReposted ? NO : YES];
    repostItem.selectionHandler = ^(void)
    {
        [self dismissViewControllerAnimated:YES
                                 completion:^
        {
            if (![VObjectManager sharedManager].mainUser)
            {
                [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
                return;
            }
            if (self.viewModel.hasReposted)
            {
                return;
            }
            
            [self.viewModel repost];
        }];
    };
    repostItem.detailSelectionHandler = ^(void)
    {
        [self dismissViewControllerAnimated:YES
                                 completion:^
        {
            VReposterTableViewController *vc = [[VReposterTableViewController alloc] init];
            vc.sequence = self.viewModel.sequence;
            [self.navigationController pushViewController:vc animated:YES];
        }];
    };
    VActionItem *shareItem = [VActionItem defaultActionItemWithTitle:NSLocalizedString(@"Share", @"")
                                                          actionIcon:[UIImage imageNamed:@"icon_share"]
                                                          detailText:self.viewModel.shareCountText];

    void (^shareHandler)(void) = ^void(void)
    {
        //Remove the styling for the mail view.
        [[VThemeManager sharedThemeManager] removeStyling];
        
        VFacebookActivity *fbActivity = [[VFacebookActivity alloc] init];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.viewModel.sequence,
                                                                                                                     self.viewModel.shareText,
                                                                                                                     self.viewModel.shareURL]
                                                                                             applicationActivities:@[fbActivity]];
        
        NSString *emailSubject = [NSString stringWithFormat:NSLocalizedString(@"EmailShareSubjectFormat", nil), [[VThemeManager sharedThemeManager] themedStringForKey:kVChannelName]];
        [activityViewController setValue:emailSubject forKey:@"subject"];
        activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook];
        activityViewController.completionHandler = ^(NSString *activityType, BOOL completed)
        {
            [[VThemeManager sharedThemeManager] applyStyling];
            [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:[NSString stringWithFormat:@"Shared %@, via %@", self.viewModel.analyticsContentTypeText, activityType]
                                                                         action:nil
                                                                          label:nil
                                                                          value:nil];
            [self reloadInputViews];
        };
        
        [self dismissViewControllerAnimated:YES
                                 completion:^
         {
             [self presentViewController:activityViewController
                                animated:YES
                              completion:nil];
         }];
    };
    shareItem.selectionHandler = shareHandler;
    shareItem.detailSelectionHandler = shareHandler;
    
    VActionItem *flagItem = [VActionItem defaultActionItemWithTitle:NSLocalizedString(@"Report/Flag", @"")
                                                         actionIcon:[UIImage imageNamed:@"icon_flag"]
                                                         detailText:nil];
    flagItem.selectionHandler = ^(void)
    {
        [[VObjectManager sharedManager] flagSequence:self.viewModel.sequence
                                        successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
         {
             UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ReportedTitle", @"")
                                                                    message:NSLocalizedString(@"ReportContentMessage", @"")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                          otherButtonTitles:nil];
             [alert show];
             
         }
                                           failBlock:^(NSOperation *operation, NSError *error)
         {
             VLog(@"Failed to flag sequence %@", self.viewModel.sequence);
             
             UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WereSorry", @"")
                                                                    message:NSLocalizedString(@"ErrorOccured", @"")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                          otherButtonTitles:nil];
             [alert show];
         }];
    };
    
    [actionSheetViewController addActionItems:@[userItem, descripTionItem, remixItem, repostItem, shareItem, flagItem]];
    
    actionSheetViewController.cancelHandler = ^void(void)
    {
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
    };
    
    [self presentViewController:actionSheetViewController
                       animated:YES
                     completion:nil];
}

#pragma mark - Private Mehods

- (NSIndexPath *)indexPathForContentView
{
    return [NSIndexPath indexPathForRow:0
                              inSection:VContentViewSectionContent];
}

- (void)configureCommentCell:(VContentCommentsCell *)commentCell
                   withIndex:(NSInteger)index
{
    commentCell.commentBody = [self.viewModel commentBodyForCommentIndex:index];
    commentCell.commenterName = [self.viewModel commenterNameForCommentIndex:index];
    commentCell.URLForCommenterAvatar = [self.viewModel commenterAvatarURLForCommentIndex:index];
    commentCell.timestampText = [self.viewModel commentTimeAgoTextForCommentIndex:index];
    commentCell.realTimeCommentText = [self.viewModel commentRealTimeCommentTextForCommentIndex:index];
    if ([self.viewModel commentHasMediaForCommentIndex:index])
    {
        commentCell.hasMedia = YES;
        commentCell.mediaPreviewURL = [self.viewModel commentMediaPreviewUrlForCommentIndex:index];
        commentCell.mediaIsVideo = [self.viewModel commentMediaIsVideoForCommentIndex:index];
    }
    
    __weak typeof(self) welf = self;
    __weak typeof(commentCell) wCommentCell = commentCell;
    commentCell.onMediaTapped = ^(void)
    {
        VLightboxViewController *lightbox;
        if (wCommentCell.mediaIsVideo)
        {
            lightbox = [[VVideoLightboxViewController alloc] initWithPreviewImage:wCommentCell.previewImage
                                                                         videoURL:[welf.viewModel mediaURLForCommentIndex:index]];
            
            ((VVideoLightboxViewController *)lightbox).onVideoFinished = lightbox.onCloseButtonTapped;
            ((VVideoLightboxViewController *)lightbox).titleForAnalytics = @"Video Realtime Comment";
        }
        else
        {
            lightbox = [[VImageLightboxViewController alloc] initWithImage:wCommentCell.previewImage];
        }
        
        lightbox.onCloseButtonTapped = ^(void)
        {
            [welf dismissViewControllerAnimated:YES completion:nil];
        };
        
        [VLightboxTransitioningDelegate addNewTransitioningDelegateToLightboxController:lightbox
                                                                          referenceView:wCommentCell.previewView];
        
        [welf presentViewController:lightbox
                           animated:YES
                         completion:nil];
    };
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    VContentViewSection vSection = section;
    switch (vSection)
    {
        case VContentViewSectionContent:
            return 1;
        case VContentViewSectionHistogram:
            return 1;
        case VContentViewSectionTicker:
            return 1;
        case VContentViewSectionAllComments:
            return self.viewModel.commentCount;
        case VContentViewSectionCount:
            return 0;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return VContentViewSectionCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VContentViewSection vSection = indexPath.section;
    switch (vSection)
    {
        case VContentViewSectionContent:
            switch (self.viewModel.type)
        {
            case VContentViewTypeInvalid:
                return nil;
            case VContentViewTypeImage:
            {
                VContentImageCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VContentImageCell suggestedReuseIdentifier]
                                                                                         forIndexPath:indexPath];
                [imageCell.contentImageView setImageWithURLRequest:self.viewModel.imageURLRequest
                                                  placeholderImage:nil
                                                           success:nil
                                                           failure:nil];
                self.contentCell = imageCell;
                return imageCell;
            }
            case VContentViewTypeVideo:
            {
                if (self.videoCell)
                {
                    return self.videoCell;
                }
                
                VContentVideoCell *videoCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VContentVideoCell suggestedReuseIdentifier]
                                                                                         forIndexPath:indexPath];
                videoCell.videoURL = self.viewModel.videoURL;
                videoCell.delegate = self;
                self.videoCell = videoCell;
                self.contentCell = videoCell;
                return videoCell;
            }
            case VContentViewTypePoll:
                return [collectionView dequeueReusableCellWithReuseIdentifier:[VContentImageCell suggestedReuseIdentifier]
                                                                 forIndexPath:indexPath];
        }
        case VContentViewSectionHistogram:
        {
            VContentImageCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VContentImageCell suggestedReuseIdentifier]
                                                                                     forIndexPath:indexPath];
            imageCell.contentView.backgroundColor = [UIColor blueColor];
            return imageCell;
        }
        case VContentViewSectionTicker:
        {
            if (self.tickerCell)
            {
                return self.tickerCell;
            }
            
            self.tickerCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VTickerCell suggestedReuseIdentifier]
                                                                                 forIndexPath:indexPath];
            return self.tickerCell;
        }
        case VContentViewSectionAllComments:
        {
            VContentCommentsCell *commentCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VContentCommentsCell suggestedReuseIdentifier]
                                                                                          forIndexPath:indexPath];
            
            [self configureCommentCell:commentCell
                             withIndex:indexPath.row];
            
            return commentCell;
        }
        case VContentViewSectionCount:
            return nil;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    VContentViewSection vSection = indexPath.section;
    switch (vSection)
    {
        case VContentViewSectionContent:
        {
            return [collectionView dequeueReusableSupplementaryViewOfKind:VShrinkingContentLayoutContentBackgroundView
                                                      withReuseIdentifier:[VContentBackgroundSupplementaryView suggestedReuseIdentifier]
                                                             forIndexPath:indexPath];
        }
            
        case VContentViewSectionHistogram:
            return nil;
        case VContentViewSectionTicker:
            return nil;
        case VContentViewSectionAllComments:
        {
            if (!self.handleView)
            {
                VSectionHandleReusableView *handleView = (self.viewModel.commentCount == 0) ? nil : [collectionView dequeueReusableSupplementaryViewOfKind:VShrinkingContentLayoutAllCommentsHandle
                                                                                                                                       withReuseIdentifier:[VSectionHandleReusableView suggestedReuseIdentifier]
                                                                                                                                              forIndexPath:indexPath];
                self.handleView = handleView;
            }
            self.handleView.numberOfComments = self.viewModel.commentCount;
            
            return self.handleView;
        }
        case VContentViewSectionCount:
            return nil;
    }
}

#pragma mark - UICollectionViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    VShrinkingContentLayout *layout = (VShrinkingContentLayout *)self.contentCollectionView.collectionViewLayout;
    
    self.bottomExperienceEnhancerBarToContainerConstraint.constant = layout.percentToShowBottomBar * CGRectGetHeight(self.experienceEnhancerBar.bounds);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VContentViewSection vSection = indexPath.section;
    switch (vSection)
    {
        case VContentViewSectionContent:
        {
            if (self.videoSizeValue)
            {
                return [self.videoSizeValue CGSizeValue];
            }
            return [VContentCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
        }
        case VContentViewSectionHistogram:
            return CGSizeMake(CGRectGetWidth(self.contentCollectionView.bounds),
                              20.0f);
        case VContentViewSectionTicker:
        {
            return CGSizeMake(CGRectGetWidth(self.contentCollectionView.bounds),
                              50.0f);
            
        }
        case VContentViewSectionAllComments:
        {
            return [VContentCommentsCell sizeWithFullWidth:CGRectGetWidth(self.contentCollectionView.bounds)
                                               commentBody:[self.viewModel commentBodyForCommentIndex:indexPath.row]
                                               andHasMedia:[self.viewModel commentHasMediaForCommentIndex:indexPath.row]];
        }
            
        case VContentViewSectionCount:
            return CGSizeZero;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
    VContentViewSection vSection = section;
    switch (vSection)
    {
        case VContentViewSectionContent:
            return CGSizeZero;
        case VContentViewSectionHistogram:
            return CGSizeZero;
        case VContentViewSectionTicker:
            return CGSizeZero;
        case VContentViewSectionAllComments:
        {
            CGSize allCommentsHandleSize = (self.viewModel.commentCount == 0) ? CGSizeZero :[VSectionHandleReusableView desiredSizeWithCollectionViewBounds:collectionView.bounds];
            ((VShrinkingContentLayout *)self.contentCollectionView.collectionViewLayout).allCommentsHandleBottomInset = allCommentsHandleSize.height;
            return allCommentsHandleSize;
        }
        case VContentViewSectionCount:
            return CGSizeZero;
    }
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:[self indexPathForContentView]] == NSOrderedSame)
    {
        [self.contentCollectionView setContentOffset:CGPointMake(0, 0)
                                            animated:YES];
    }
}

#pragma mark - VContentVideoCellDelgetate

- (void)videoCell:(VContentVideoCell *)videoCell
    didPlayToTime:(CMTime)time
        totalTime:(CMTime)totalTime
{
    self.textEntryView.placeholderText = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LeaveACommentAt", @""), [self.elapsedTimeFormatter stringForCMTime:time]];
}

- (void)videoCellReadyToPlay:(VContentVideoCell *)videoCell
{
    // should we update content size?
    CGSize desiredSizeForVideo = AVMakeRectWithAspectRatioInsideRect(videoCell.videoPlayerViewController.naturalSize, CGRectMake(0, 0, 320, 320)).size;
    if (!isnan(desiredSizeForVideo.width) && !isnan(desiredSizeForVideo.height))
    {
        if (desiredSizeForVideo.height > desiredSizeForVideo.width)
        {
            desiredSizeForVideo = CGSizeMake(CGRectGetWidth(self.contentCollectionView.bounds), CGRectGetWidth(self.contentCollectionView.bounds));
        }
        desiredSizeForVideo.width = CGRectGetWidth(self.contentCollectionView.bounds);
        self.videoSizeValue = [NSValue valueWithCGSize:desiredSizeForVideo];
    }
    
    [UIView animateWithDuration:0.0f
                     animations:^
     {
         [self.contentCollectionView.collectionViewLayout invalidateLayout];
     }];
}

- (void)videoCellPlayedToEnd:(VContentVideoCell *)videoCell
               withTotalTime:(CMTime)totalTime
{
    self.textEntryView.placeholderText = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LeaveACommentAt", @""), [self.elapsedTimeFormatter stringForCMTime:totalTime]];
}

#pragma mark - VKeyboardInputAccessoryViewDelegate

- (void)keyboardInputAccessoryView:(VKeyboardInputAccessoryView *)inpoutAccessoryView
                         wantsSize:(CGSize)size
{
    self.keyboardInputBarHeightConstraint.constant = size.height;
    [self.view layoutIfNeeded];
}

- (void)pressedSendOnKeyboardInputAccessoryView:(VKeyboardInputAccessoryView *)inputAccessoryView
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    __weak typeof(self) welf = self;
    [self.viewModel addCommentWithText:inputAccessoryView.composedText
                              mediaURL:self.mediaURL
                            completion:^(BOOL succeeded)
     {
         [welf.viewModel fetchComments];
         [UIView animateWithDuration:0.0f
                          animations:^
          {
              [welf.contentCollectionView reloadData];
              [welf.contentCollectionView.collectionViewLayout invalidateLayout];
          }];
     }];
    
    [inputAccessoryView clearTextAndResign];
    self.mediaURL = nil;
}

- (void)pressedAttachmentOnKeyboardInputAccessoryView:(VKeyboardInputAccessoryView *)inputAccessoryView
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    VCameraViewController *cameraViewController = [VCameraViewController cameraViewController];
    cameraViewController.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        if (finished)
        {
            self.mediaURL = capturedMediaURL;
            [self.textEntryView setSelectedThumbnail:previewImage];
        }
        [self dismissViewControllerAnimated:YES completion:^
        {
            [UIView animateWithDuration:0.0f
                             animations:^
             {
                 [self.contentCollectionView reloadData];
                 [self.contentCollectionView.collectionViewLayout invalidateLayout];
             }];
        }];
    };
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:cameraViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

@end
