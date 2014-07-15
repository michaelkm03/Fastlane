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

#import "VThemeManager.h"

#import "NSDate+timeSince.h"

static char VRealtimeCommentKVOContext;

static const CGFloat kVRealtimeCommentTimeout = 1.0f;

@interface VRealtimeCommentViewController ()

@property (nonatomic, weak) IBOutlet UIView* progressBackgroundView;
@property (nonatomic, weak) IBOutlet UIView* progressBarView;
@property (nonatomic, weak) IBOutlet UIView* commentBackgroundView;

@property (nonatomic, weak) IBOutlet UIImageView* profileImageView;
@property (nonatomic, weak) IBOutlet UIImageView* mediaImageView;
@property (nonatomic, weak) IBOutlet UIImageView* arrowImageView;

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
    
    self.progressBarImageViews = [[NSMutableArray alloc] init];
    self.arrowImageView.image = [self.arrowImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.arrowImageView.tintColor = self.commentBackgroundView.backgroundColor;
}

#pragma mark - Comment Selection
- (IBAction)respondToCommentSelection:(UITapGestureRecognizer *)recognizer
{
    
}

#pragma mark - Getters

- (CGFloat)endTime
{
    return (isnan(_endTime) || _endTime == 0) ? CGFLOAT_MAX : _endTime;
}

#pragma mark - Setters
- (void)setComments:(NSArray *)comments
{
    _comments = comments;
    
#warning Sort the comments so they are guarenteed to be in the right order
    
    for (UIImageView* imageView in self.progressBarImageViews)
        [imageView removeFromSuperview];
    [self.progressBarImageViews removeAllObjects];
    
    for (VComment* comment in comments)
    {
        CGFloat startTime = [self.comments indexOfObject:comment] * (self.endTime / self.comments.count);
        CGFloat imageHeight = self.progressBackgroundView.frame.size.height * .75;
        UIImageView* progressBarImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageHeight, imageHeight)];
        progressBarImage.layer.cornerRadius = CGRectGetHeight(progressBarImage.bounds)/2;
        progressBarImage.clipsToBounds = YES;

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
    
    VComment* currentComment;
    for (VComment* comment in self.comments)
    {
        CGFloat startTime = [self.comments indexOfObject:comment] * (self.endTime / self.comments.count);
        if (startTime < currentTime && currentTime-startTime < kVRealtimeCommentTimeout)
            currentComment = comment;
        else if (startTime > currentTime)
            break;
    }
    
    self.currentComment = currentComment;
    
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
        return;
    
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
    
    self.mediaImageView.hidden = !currentComment.mediaUrl;
    if (currentComment.mediaUrl && currentComment.mediaType.length)
        [self.mediaImageView setImageWithURL:currentComment.mediaUrl];
}

@end
