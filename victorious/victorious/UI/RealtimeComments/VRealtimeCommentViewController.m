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

static char VRealtimeCommentKVOContext;


@interface VRealtimeCommentViewController ()

@property (nonatomic, weak) IBOutlet UIView* progressBackgroundView;
@property (nonatomic, weak) IBOutlet UIView* progressBarView;
@property (nonatomic, weak) IBOutlet UIView* commentBackgroundView;

@property (nonatomic, weak) IBOutlet UIImageView* profileImageView;
@property (nonatomic, weak) IBOutlet UIImageView* mediaImageView;

@property (nonatomic, weak) IBOutlet UILabel* timeLabel;
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UILabel* commentLabel;

@property (nonatomic, strong) VComment* currentComment;

@end

@implementation VRealtimeCommentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setComments:(NSArray *)comments
{
    _comments = comments;
    
#warning Sort the comments so they are guarenteed to be in the right order
}

- (void)setCurrentTime:(CMTime)currentTime
{
//    CMTime* oldTime = _currentTime;
    _currentTime = currentTime;
    
    CGFloat currentSecond = (CGFloat)currentTime.value / (CGFloat)currentTime.timescale;
    CGFloat endSecond = (CGFloat)self.endTime.value / (CGFloat)self.endTime.timescale;
    
    CGRect frame = self.progressBarView.frame;
    frame.size.width = (currentSecond / endSecond) * self.progressBackgroundView.frame.size.width;
    self.progressBarView.frame = frame;
    
    VComment* currentComment;
    for (VComment* comment in self.comments)
    {
        CMTime startTime = CMTimeMake(0, 1);
        if (CMTimeCompare(startTime, currentTime) <= 0 )
            currentComment = comment;
        else
            break;
    }
    
    self.currentComment = currentComment;
}

- (void)setCurrentComment:(VComment *)currentComment
{
    if ([currentComment.remoteId isEqualToValue:_currentComment.remoteId])
        return;
    
    _currentComment = currentComment;
    [self.profileImageView setImageWithURL:[NSURL URLWithString:_currentComment.user.pictureUrl] placeholderImage:[UIImage imageNamed:@"profile_full"]];
//    self.timeLabel.text = _currentComment.postedAt;
    
    self.commentLabel.text = currentComment.text;
    
    NSString* fullString = currentComment.user.name;
    NSMutableAttributedString* nameString = [[NSMutableAttributedString alloc] initWithString:fullString];
    [nameString addAttribute:NSForegroundColorAttributeName value: [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor]
                       range:NSMakeRange(0, currentComment.user.name.length)];
    [nameString addAttribute:NSFontAttributeName value:[[VThemeManager sharedThemeManager] themedFontForKey:kVLabel2Font]
                       range:NSMakeRange(0, fullString.length)];
    self.nameLabel.attributedText = nameString;
    
    self.mediaImageView.hidden = !currentComment.mediaUrl;
    if (currentComment.mediaUrl)
        [self.mediaImageView setImageWithURL:currentComment.mediaUrl];
}

@end
