//
//  VRealtimeCommentViewController.m
//  victorious
//
//  Created by Will Long on 7/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VRealtimeCommentViewController.h"

#import "VComment+Fetcher.h"
#import "VUser.h"

#import "VConstants.h"
#import "VThemeManager.h"

#import "UIButton+VImageLoading.h"
#import "NSDate+timeSince.h"

#import "VVideoLightboxViewController.h"
#import "VImageLightboxViewController.h"
#import "VLightboxTransitioningDelegate.h"

#import "UIImage+ImageCreation.h"

static const CGFloat kVRealtimeCommentTimeout = 2.0f;

@interface VRealtimeCommentViewController ()

@property (nonatomic, weak) IBOutlet UIView* progressBackgroundView;
@property (nonatomic, weak) IBOutlet UIView* progressBarView;
@property (nonatomic, weak) IBOutlet UIView* commentBackgroundView;

@property (nonatomic, weak) IBOutlet UIImageView* profileImageView;
@property (nonatomic, weak) IBOutlet UIImageView* arrowImageView;

@property (nonatomic, weak) IBOutlet UIImageView* playButtonImageView;
@property (nonatomic, weak) IBOutlet UIButton* mediaButton;

@property (nonatomic, weak) IBOutlet UILabel* timeLabel;
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UILabel* commentLabel;

@property (nonatomic, strong) VComment* currentComment;

@property (nonatomic, strong) NSMutableArray* progressBarImageViews;

@property (nonatomic)   BOOL didSelectComment;

@end

@implementation VRealtimeCommentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *commentSelectionRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(respondToCommentSelection:)];
    commentSelectionRecognizer.numberOfTapsRequired = 1;
    [self.progressBackgroundView addGestureRecognizer:commentSelectionRecognizer];
    
    self.profileImageView.layer.cornerRadius = CGRectGetHeight(self.profileImageView.bounds)/2;
    self.profileImageView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    
    self.progressBarImageViews = [[NSMutableArray alloc] init];
    self.arrowImageView.image = [self.arrowImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.arrowImageView.tintColor = self.commentBackgroundView.backgroundColor;
    
    self.commentLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    self.timeLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
}

#pragma mark - Comment Selection
- (IBAction)respondToCommentSelection:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.progressBackgroundView];
    CGFloat timeAtTouch = (location.x / self.progressBackgroundView.frame.size.width) * self.endTime;
    self.didSelectComment = YES;
    self.currentComment = [self commentAtTime:timeAtTouch];
}

- (VComment*)commentAtTime:(CGFloat)time
{
    VComment* currentComment;
    for (VComment* comment in self.comments)
    {
        CGFloat startTime = comment.timeInMedia.floatValue;
        if (startTime < time && time-startTime < kVRealtimeCommentTimeout)
            currentComment = comment;
        else if (startTime > time)
            break;
    }
    return currentComment;
}

#pragma mark - Getters

- (CGFloat)endTime
{
    return (isnan(_endTime) || _endTime == 0) ? CGFLOAT_MAX : _endTime;
}

#pragma mark - Setters
- (void)setComments:(NSArray *)comments
{
    for (UIImageView* imageView in self.progressBarImageViews)
        [imageView removeFromSuperview];
    [self.progressBarImageViews removeAllObjects];
    
    #warning replace this with real start time
    for (VComment* comment in comments)
    {
        if (comment.timeInMedia.floatValue <= 0.0f || comment.timeInMedia.floatValue > self.endTime)
        {
            CGFloat startTime = self.endTime * drand48();
            comment.timeInMedia = @(startTime);
        }
    }
    
    NSSortDescriptor*   sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeInMedia" ascending:YES];
    
    _comments = [comments sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    for (VComment* comment in _comments)
    {
        CGFloat startTime = comment.timeInMedia.floatValue;
        
        CGFloat imageHeight = self.progressBackgroundView.frame.size.height * .75;
        UIImageView* progressBarImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageHeight, imageHeight)];
        progressBarImage.layer.cornerRadius = CGRectGetHeight(progressBarImage.bounds)/2;
        progressBarImage.clipsToBounds = YES;
        progressBarImage.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];

        CGFloat xCenter = self.progressBackgroundView.frame.size.width - imageHeight;
        xCenter = xCenter * (startTime / self.endTime);
        xCenter += imageHeight / 2;
        
        progressBarImage.center = CGPointMake(xCenter, self.progressBackgroundView.frame.size.height / 2);
        [progressBarImage setImageWithURL:[NSURL URLWithString:comment.user.pictureUrl]
                         placeholderImage:[UIImage imageNamed:@"profile_thumb"]];

        [self.progressBackgroundView addSubview:progressBarImage];
        [self.progressBarImageViews addObject:progressBarImage];
        
        VLog(@"Frame: %@", NSStringFromCGRect(progressBarImage.frame));
    }
}

- (void)setCurrentTime:(CGFloat)currentTime
{
    CGFloat oldTime = _currentTime;
    _currentTime = currentTime;
    
    if (!self.didSelectComment)
        self.currentComment = [self commentAtTime:currentTime];
    
    [UIView animateWithDuration:currentTime - oldTime
                     animations:
     ^{
         CGRect frame = self.progressBarView.frame;
         frame.size.width = (currentTime / self.endTime) * self.progressBackgroundView.frame.size.width;
         self.progressBarView.frame = frame;
     }
                     completion:nil];
}

- (void)setCurrentComment:(VComment *)currentComment
{
    if (currentComment)
    {
        UIImageView* imageView = [self.progressBarImageViews objectAtIndex:[self.comments indexOfObject:currentComment]];
        self.arrowImageView.center = CGPointMake(imageView.center.x, self.arrowImageView.center.y);
        [UIView animateWithDuration:.25f animations:
         ^{
             self.commentBackgroundView.alpha = 1;
         }];
    }
    else if (!currentComment)
    {
        [UIView animateWithDuration:.25f animations:
         ^{
             self.commentBackgroundView.alpha = 0;
         }];
    }
    
    _currentComment = currentComment;
    
    if (!currentComment)
    {
        self.didSelectComment = NO;
        return;
    }
    
    [self.profileImageView setImageWithURL:[NSURL URLWithString:_currentComment.user.pictureUrl] placeholderImage:[UIImage imageNamed:@"profile_full"]];
    self.timeLabel.text = [_currentComment.postedAt timeSince];
    
    self.commentLabel.text = currentComment.text;
    
    NSString* fullString = currentComment.user.name ?: @"";
    NSMutableAttributedString* nameString = [[NSMutableAttributedString alloc] initWithString:fullString];
    [nameString addAttribute:NSForegroundColorAttributeName value: [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor]
                       range:NSMakeRange(0, currentComment.user.name.length)];
    [nameString addAttribute:NSFontAttributeName value:[[VThemeManager sharedThemeManager] themedFontForKey:kVLabel2Font]
                       range:NSMakeRange(0, fullString.length)];
    self.nameLabel.attributedText = nameString;
    
    self.playButtonImageView.hidden = !currentComment.mediaType || ![currentComment.mediaType isEqualToString:VConstantsMediaTypeVideo];
    if (currentComment.thumbnailUrl && currentComment.thumbnailUrl.length)
    {
        self.mediaButton.alpha = 1;
        [self.mediaButton setImageWithURL:[NSURL URLWithString:currentComment.thumbnailUrl]
                         placeholderImage:[UIImage resizeableImageWithColor:[UIColor clearColor]]
                                 forState:UIControlStateNormal];
    }
    else
        self.mediaButton.alpha = 0;
}

- (IBAction)pressedMedia:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(willShowRTCMedia)])
        [self.delegate willShowRTCMedia];
    
    
    VLightboxViewController* lightbox;
    if ([self.currentComment.mediaType isEqualToString:VConstantsMediaTypeVideo])
    {
        lightbox = [[VVideoLightboxViewController alloc] initWithPreviewImage:self.mediaButton.imageView.image
                                                                     videoURL:[NSURL URLWithString: self.currentComment.mediaUrl]];
        
        ((VVideoLightboxViewController*)lightbox).onVideoFinished = lightbox.onCloseButtonTapped;
        ((VVideoLightboxViewController*)lightbox).titleForAnalytics = @"Video Realtime Comment";
    }
    else if ([self.currentComment.mediaType isEqualToString:VConstantsMediaTypeImage])
    {
        lightbox = [[VImageLightboxViewController alloc] initWithImage:self.mediaButton.imageView.image];
    }
    lightbox.onCloseButtonTapped = ^(void)
    {
        if ([self.delegate respondsToSelector:@selector(didFinishedRTCMedia)])
            [self.delegate didFinishedRTCMedia];
        
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    };
    
    [VLightboxTransitioningDelegate addNewTransitioningDelegateToLightboxController:lightbox referenceView:self.mediaButton];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25 * NSEC_PER_SEC)), dispatch_get_main_queue(),
                   ^{
                       [self.parentViewController presentViewController:lightbox animated:YES completion:nil];
                   });
}

@end
