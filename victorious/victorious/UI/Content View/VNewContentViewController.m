 //
//  VNewContentViewController.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNewContentViewController.h"

// Layout
#import "VCollapsingFlowLayout.h"

// Cells
#import "VContentCell.h"
#import "VContentVideoCell.h"
#import "VContentImageCell.h"
#import "VRealTimeCommentsCell.h"
#import "VContentCommentsCell.h"

// Supplementary Views
#import "VSectionHandleReusableView.h"
#import "VDropdownTitleView.h"

// Input Acceossry
#import "VKeyboardInputAccessoryView.h"

// Models Ugh
#import "VComment.h"
#import "VUser.h"

typedef NS_ENUM(NSInteger, VContentViewSection)
{
    VContentViewSectionContent,
    VContentViewSectionRealTimeComments,
    VContentViewSectionAllComments,
    VContentViewSectionCount
};

@interface VNewContentViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, VKeyboardInputAccessoryViewDelegate>

@property (nonatomic, strong, readwrite) VContentViewViewModel *viewModel;

@property (nonatomic, weak) IBOutlet UICollectionView *contentCollectionView;
@property (nonatomic, weak) IBOutlet UIImageView *blurredBackgroundImageView;
@property (nonatomic, readwrite) VKeyboardInputAccessoryView *inputAccessoryView;

@end

@implementation VNewContentViewController

#pragma mark - Factory Methods

+ (VNewContentViewController *)contentViewControllerWithViewModel:(VContentViewViewModel *)viewModel
{
    VNewContentViewController *contentViewController = [[UIStoryboard storyboardWithName:@"ContentView" bundle:nil] instantiateInitialViewController];
    
    contentViewController.viewModel = viewModel;
    
    [[NSNotificationCenter defaultCenter] addObserver:contentViewController
                                             selector:@selector(commentsDidUpdate:)
                                                 name:VContentViewViewModelDidUpdateCommentsNotification
                                               object:viewModel];
    
    return contentViewController;
}

#pragma mark - Dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - UIViewController

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.inputAccessoryView = [VKeyboardInputAccessoryView defaultInputAccessoryView];
    self.inputAccessoryView.delegate = self;
    self.inputAccessoryView.frame = CGRectMake(0,
                                               CGRectGetHeight(self.view.bounds) - self.inputAccessoryView.intrinsicContentSize.height,
                                               CGRectGetWidth(self.view.bounds),
                                               self.inputAccessoryView.intrinsicContentSize.height);
    [self.view addSubview:self.inputAccessoryView];

    self.contentCollectionView.contentInset = UIEdgeInsetsMake(0, 0, self.inputAccessoryView.bounds.size.height, 0);
    self.contentCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    // Register nibs
    [self.contentCollectionView registerNib:[VContentCell nibForCell]
                 forCellWithReuseIdentifier:[VContentCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VContentVideoCell nibForCell]
                 forCellWithReuseIdentifier:[VContentVideoCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VContentImageCell nibForCell]
                 forCellWithReuseIdentifier:[VContentImageCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VRealTimeCommentsCell  nibForCell]
                 forCellWithReuseIdentifier:[VRealTimeCommentsCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VContentCommentsCell nibForCell]
                 forCellWithReuseIdentifier:[VContentCommentsCell suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VSectionHandleReusableView nibForCell]
                 forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                        withReuseIdentifier:[VSectionHandleReusableView suggestedReuseIdentifier]];
    [self.contentCollectionView registerNib:[VDropdownTitleView nibForCell]
                 forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                        withReuseIdentifier:[VDropdownTitleView suggestedReuseIdentifier]];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    
    // There is a bug where input accessory view will go offscreen and not remain docked on first dismissal of the keyboard. This fixes that.
    [self becomeFirstResponder];
    [self resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.contentCollectionView flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.inputAccessoryView removeFromSuperview];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Notification Handlers

- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIEdgeInsets newInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(endFrame), 0);
    self.contentCollectionView.contentInset = newInsets;
    self.contentCollectionView.scrollIndicatorInsets = newInsets;
    
    VCollapsingFlowLayout *layout = (VCollapsingFlowLayout *)self.contentCollectionView.collectionViewLayout;
    
    self.inputAccessoryView.maximumAllowedSize = CGSizeMake(CGRectGetWidth(self.view.frame),
                                                            CGRectGetHeight(self.view.frame) - CGRectGetHeight(endFrame) - layout.dropDownHeaderMiniumHeight + CGRectGetHeight(self.inputAccessoryView.frame));
}

- (void)commentsDidUpdate:(NSNotification *)notification
{
    NSIndexSet *commentsIndexSet = [NSIndexSet indexSetWithIndex:VContentViewSectionAllComments];
    [self.contentCollectionView reloadSections:commentsIndexSet];
}

#pragma mark - IBActions

- (IBAction)pressedClose:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

#pragma mark - Convenience

- (NSIndexPath *)indexPathForContentView
{
    return [NSIndexPath indexPathForRow:0
                              inSection:VContentViewSectionContent];
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
        case VContentViewSectionRealTimeComments:
            return 1;
        case VContentViewSectionAllComments:
            return self.viewModel.comments.count;
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
                return imageCell;
            }
            case VContentViewTypeVideo:
            {
                VContentVideoCell *videoCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VContentVideoCell suggestedReuseIdentifier]
                                                                                         forIndexPath:indexPath];
                videoCell.videoURL = self.viewModel.videoURL;
                return videoCell;
            }
            case VContentViewTypePoll:
                return [collectionView dequeueReusableCellWithReuseIdentifier:[VContentCell suggestedReuseIdentifier]
                                                                 forIndexPath:indexPath];
        }
        case VContentViewSectionRealTimeComments:
            return [collectionView dequeueReusableCellWithReuseIdentifier:[VRealTimeCommentsCell suggestedReuseIdentifier]
                                                             forIndexPath:indexPath];
        case VContentViewSectionAllComments:
        {
            VContentCommentsCell *commentCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VContentCommentsCell suggestedReuseIdentifier]
                                                                                          forIndexPath:indexPath];
            
            VComment *commentForIndexPath = [self.viewModel.comments objectAtIndex:indexPath.row];
            
            [self configureCommentCell:commentCell
                           withComment:commentForIndexPath];
            
            
            
            return commentCell;
        }
        case VContentViewSectionCount:
            return nil;
    }
}

- (void)configureCommentCell:(VContentCommentsCell *)commentCell
                 withComment:(VComment *)comment
{
    commentCell.commentBodyTextView.text = comment.text;
    commentCell.commentersUsernameLabel.text = comment.user.name;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    VContentViewSection vSection = indexPath.section;
    switch (vSection)
    {
        case VContentViewSectionContent:
            return [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                      withReuseIdentifier:[VDropdownTitleView suggestedReuseIdentifier]
                                                             forIndexPath:indexPath];
        case VContentViewSectionRealTimeComments:
            return nil;
        case VContentViewSectionAllComments:
            return (self.viewModel.comments.count == 0) ? nil : [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                   withReuseIdentifier:[VSectionHandleReusableView suggestedReuseIdentifier]
                                                                                                          forIndexPath:indexPath];
        case VContentViewSectionCount:
            return nil;
    }
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VContentViewSection vSection = indexPath.section;
    switch (vSection)
    {
        case VContentViewSectionContent:
            return [VContentCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
        case VContentViewSectionRealTimeComments:
            return [VRealTimeCommentsCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
        case VContentViewSectionAllComments:
            return [VContentCommentsCell desiredSizeWithCollectionViewBounds:self.contentCollectionView.bounds];
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
        case VContentViewSectionRealTimeComments:
            return CGSizeZero;
        case VContentViewSectionAllComments:
            return (self.viewModel.comments.count == 0) ? CGSizeZero : [VSectionHandleReusableView desiredSizeWithCollectionViewBounds:collectionView.bounds];
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

#pragma mark UIScrollView

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    void (^delayedContentOffsetBlock)(void);
    
    VCollapsingFlowLayout *layout = (VCollapsingFlowLayout *)self.contentCollectionView.collectionViewLayout;
    
    if (targetContentOffset->y < (layout.dropDownHeaderMiniumHeight*0.5f))
    {
        if (velocity.y > 0.0f)
        {
            delayedContentOffsetBlock = ^void(void)
            {
                [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            };
        }
        else
        {
            *targetContentOffset = CGPointMake(0, 0);
        }
    }
    else if ( (targetContentOffset->y >= (layout.dropDownHeaderMiniumHeight * 0.5f)) && (targetContentOffset->y < (layout.dropDownHeaderMiniumHeight)))
    {
        if (velocity.y > 0.0f)
        {
            *targetContentOffset = CGPointMake(0, layout.dropDownHeaderMiniumHeight);
        }
        else
        {
            delayedContentOffsetBlock = ^void(void)
            {
                [scrollView setContentOffset:CGPointMake(0, layout.dropDownHeaderMiniumHeight)
                                    animated:YES];
            };
        }
    }
    else if ((targetContentOffset->y >= layout.dropDownHeaderMiniumHeight) && (targetContentOffset->y < (layout.dropDownHeaderMiniumHeight + (layout.sizeForContentView.height * 0.5f))))
    {
        if (velocity.y < 0.0f)
        {
            *targetContentOffset = CGPointMake(0, layout.dropDownHeaderMiniumHeight);
        }
        else
        {
            delayedContentOffsetBlock = ^void(void)
            {
                [scrollView setContentOffset:CGPointMake(0.0f, layout.dropDownHeaderMiniumHeight)
                                    animated:YES];
            };
        }
    }
    else if (
             (targetContentOffset->y >= (layout.dropDownHeaderMiniumHeight + (layout.sizeForContentView.height * 0.5f)))
             &&
             (targetContentOffset->y < (layout.dropDownHeaderMiniumHeight + layout.sizeForContentView.height))
             &&
             (targetContentOffset->y < (layout.sizeForContentView.height))
            )
    {
        if (velocity.y > 0.0f)
        {
            *targetContentOffset = CGPointMake(0, layout.sizeForContentView.height);
        }
        else
        {
            delayedContentOffsetBlock = ^void(void)
            {
                [scrollView setContentOffset:CGPointMake(0, layout.sizeForContentView.height) animated:YES];
            };
        }
    }
    
    if (delayedContentOffsetBlock)
    {
        // This is done to prevent cases where merely setting targetContentOffset lead to jumpy scrolling
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
        {
            delayedContentOffsetBlock();
        });
    }
}

#pragma mark - VKeyboardInputAccessoryViewDelegate

- (void)keyboardInputAccessoryView:(VKeyboardInputAccessoryView *)inpoutAccessoryView
                         wantsSize:(CGSize)size
{
    self.inputAccessoryView.frame = CGRectMake(0, 0, size.width, size.height);
    [self.inputAccessoryView layoutIfNeeded];
}

- (void)pressedSendOnKeyboardInputAccessoryView:(VKeyboardInputAccessoryView *)inputAccessoryView
{
//TODO: Implement adding a comment
}

- (void)pressedAttachmentOnKeyboardInputAccessoryView:(VKeyboardInputAccessoryView *)inputAccessoryView
{
//TODO: Implement the ability to select an item from the camera roll/etc.
}

@end
