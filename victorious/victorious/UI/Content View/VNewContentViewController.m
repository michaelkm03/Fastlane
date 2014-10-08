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
#import "VHistogramView.h"

// View Categories
#import "UIView+VShadows.h"

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
#import "VHistogramCell.h"

// Supplementary Views
#import "VSectionHandleReusableView.h"
#import "VContentBackgroundSupplementaryView.h"

// Input Acceossry
#import "VKeyboardInputAccessoryView.h"

// ViewControllers
#import "VCameraViewController.h"
#import "VVideoLightboxViewController.h"
#import "VImageLightboxViewController.h"

// Transitioning
#import "VLightboxTransitioningDelegate.h"

// Logged in
#import "VObjectManager+Login.h"
#import "VLoginViewController.h"

// Formatters
#import "VElapsedTimeFormatter.h"

// Simple Models
#import "VExperienceEnhancer.h"

static const CGFloat kExperienceEnhancerShadowRadius = 1.5f;
static const CGFloat kExperienceEnhancerShadowOffsetY = -1.5f;
static const CGFloat kExperienceEnhancerShadowWidthOverdraw = 5.0f;
static const CGFloat kExperienceEnhancerShadowAlpha = 0.2f;

@interface VNewContentViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate,VKeyboardInputAccessoryViewDelegate,VContentVideoCellDelgetate, VHistogramDataSource>

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
@property (nonatomic, weak) VHistogramCell *histogramCell;

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
    self.experienceEnhancerBar.selectionBlock = ^(VExperienceEnhancer *selectedEnhancer, CGPoint selectionCenter)
    {
        if (selectedEnhancer.isBallistic)
        {
            UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, selectedEnhancer.flightImage.size.width, selectedEnhancer.flightImage.size.height)];
            animationImageView.contentMode = UIViewContentModeScaleAspectFit;
            
            CGPoint convertedCenterForAnimation = [experienceEnhancerBar convertPoint:selectionCenter toView:self.view];
            animationImageView.center = convertedCenterForAnimation;
            animationImageView.image = selectedEnhancer.flightImage;
            [self.view addSubview:animationImageView];
            
            [UIView animateWithDuration:selectedEnhancer.flightDuration
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^
            {
                CGFloat randomLocationX = fminf(fmaxf(arc4random_uniform(CGRectGetWidth(self.contentCell.bounds)), (CGRectGetWidth(animationImageView.bounds) * 0.5f)), CGRectGetWidth(self.contentCell.bounds) - (CGRectGetWidth(animationImageView.bounds) * 0.5f));
                CGFloat randomLocationY = fminf(fmaxf(arc4random_uniform(CGRectGetHeight(self.contentCell.bounds)), (CGRectGetHeight(animationImageView.bounds) * 0.5f)), CGRectGetHeight(self.contentCell.bounds) - (CGRectGetHeight(animationImageView.bounds) * 0.5f));
                
                CGPoint contentCenter = [self.view convertPoint:CGPointMake(randomLocationX, randomLocationY)
                                                       fromView:self.contentCell];
                animationImageView.center = contentCenter;

            }
                             completion:^(BOOL finished)
            {
                animationImageView.animationDuration = selectedEnhancer.animationDuration;
                animationImageView.animationImages = selectedEnhancer.animationSequence;
                animationImageView.animationRepeatCount = 1;
                animationImageView.image = nil;
                [animationImageView startAnimating];
                

                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(selectedEnhancer.animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                {
                    [animationImageView removeFromSuperview];
                });
            }];
        }
        else // full overlay
        {
            UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:self.contentCell.bounds];
            animationImageView.animationDuration = selectedEnhancer.animationDuration;
            animationImageView.animationImages = selectedEnhancer.animationSequence;
            animationImageView.animationRepeatCount = 1;
            
            [self.contentCell.contentView addSubview:animationImageView];
            [animationImageView startAnimating];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(selectedEnhancer.animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
            {
                [animationImageView removeFromSuperview];
            });
        }
    };
    
    self.experienceEnhancerBar.layer.shadowOffset = CGSizeMake(0, 0);
    self.experienceEnhancerBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.experienceEnhancerBar.layer.shadowRadius = kExperienceEnhancerShadowRadius;
    self.experienceEnhancerBar.layer.shadowOpacity = kExperienceEnhancerShadowAlpha;
    self.experienceEnhancerBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectInset(self.experienceEnhancerBar.bounds, -kExperienceEnhancerShadowWidthOverdraw, 0)].CGPath;
    
    self.viewModel.experienceEnhancerController.enhancerBar = experienceEnhancerBar;
    
    VShrinkingContentLayout *layout = (VShrinkingContentLayout *)self.contentCollectionView.collectionViewLayout;
    layout.allCommentsHandleBottomInset = CGRectGetHeight(self.experienceEnhancerBar.bounds);
    
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
    [self.contentCollectionView registerNib:[VHistogramCell nibForCell]
                 forCellWithReuseIdentifier:[VHistogramCell suggestedReuseIdentifier]];
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
    
    VShrinkingContentLayout *layout = (VShrinkingContentLayout *)self.contentCollectionView.collectionViewLayout;
    self.contentCollectionView.contentInset = UIEdgeInsetsMake(0, 0, -layout.allCommentsHandleBottomInset + CGRectGetHeight(self.textEntryView.bounds), 0);
    self.contentCollectionView.scrollIndicatorInsets = UIEdgeInsetsMake(VShrinkingContentLayoutMinimumContentHeight,
                                                                        0,
                                                                        CGRectGetHeight(self.textEntryView.bounds), 0);
    
    [self.blurredBackgroundImageView setBlurredImageWithClearImage:self.placeholderImage
                                                  placeholderImage:[UIImage resizeableImageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]]
                                                         tintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];

    if (self.viewModel.type == VContentViewTypeVideo)
    {
        self.textEntryView.placeholderText = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LeaveACommentAt", @""), [self.elapsedTimeFormatter stringForCMTime:self.videoCell.videoPlayerViewController.currentTime]];
    }
    else
    {
        self.textEntryView.placeholderText = NSLocalizedString(@"LaveAComment", @"");
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.contentCollectionView flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.contentCollectionView.delegate = nil;
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent
                     animated:(BOOL)flag
                   completion:(void (^)(void))completion
{
    [super presentViewController:viewControllerToPresent
                        animated:flag
                      completion:completion];
    
    // Pause playback on presentation
    [self.videoCell.videoPlayerViewController.player pause];
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
    }
    else if ([notification.name isEqualToString:UIKeyboardDidChangeFrameNotification])
    {
        VShrinkingContentLayout *layout = (VShrinkingContentLayout *)self.contentCollectionView.collectionViewLayout;
        CGFloat newBottomInset = CGRectGetHeight(self.view.bounds) - CGRectGetMinY(endFrame) - layout.allCommentsHandleBottomInset + CGRectGetHeight(self.textEntryView.bounds);
        newBottomInset = (isnan(newBottomInset) || isinf(newBottomInset)) ? -layout.allCommentsHandleBottomInset + CGRectGetHeight(self.textEntryView.bounds) : newBottomInset;
        self.contentCollectionView.contentInset = UIEdgeInsetsMake(0, 0, newBottomInset, 0);
        self.contentCollectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, newBottomInset + layout.allCommentsHandleBottomInset, 0);
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
                                                  placeholderImage:self.placeholderImage?:nil
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
            if (self.histogramCell)
            {
                return self.histogramCell;
            }
            self.histogramCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VHistogramCell suggestedReuseIdentifier]
                                                                                     forIndexPath:indexPath];
            
            self.histogramCell.histogramView.dataSource = self;
            [self.histogramCell.histogramView reloadData];
            
            return self.histogramCell;
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
    self.experienceEnhancerBar.layer.shadowOffset = CGSizeMake(0, -kExperienceEnhancerShadowOffsetY * (layout.percentToShowBottomBar));
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
    
    self.histogramCell.histogramView.progress = CMTimeGetSeconds(time) / CMTimeGetSeconds(totalTime);
    
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
     }completion:^(BOOL finished) {
         if (!self.hasAutoPlayed)
         {
             [self.videoCell play];
             self.hasAutoPlayed = YES;
         }
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
            if (finished)
            {
                [self.textEntryView startEditing];
            }
            
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

#pragma mark - VHistogramDataSource

- (CGFloat)histogram:(VHistogramView *)histogramView
 heightForSliceIndex:(NSInteger)sliceIndex
         totalSlices:(NSInteger)totalSlices
{
    return arc4random_uniform(CGRectGetHeight(histogramView.bounds));
}

@end
