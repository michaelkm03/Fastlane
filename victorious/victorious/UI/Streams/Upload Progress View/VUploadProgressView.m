//
//  VUploadProgressView.m
//  victorious
//
//  Created by Josh Hinman on 10/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VThemeManager.h"
#import "VUploadManager.h"
#import "VUploadProgressView.h"
#import "VUploadTaskInformation.h"

static const NSTimeInterval kAnimationDuration = 0.1;
static const CGFloat kAccessoryButtonWidth = 44.0f;

@interface VUploadProgressView ()

@property (nonatomic, weak) IBOutlet UIImageView *previewImageView;
@property (nonatomic, weak) IBOutlet UIView *progressBackgroundView;
@property (nonatomic, weak) IBOutlet UIView *progressView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *progressWidthConstraint;
@property (nonatomic, weak) IBOutlet UIView *uploadingIcon;
@property (nonatomic, weak) IBOutlet UIView *finalizingIcon;
@property (nonatomic, weak) IBOutlet UIView *failedIcon;
@property (nonatomic, weak) IBOutlet UIImageView *alternateFailedIcon;
@property (nonatomic, weak) IBOutlet UIView *finishedIcon;
@property (nonatomic, weak) IBOutlet UIImageView *finishedIconCheckmark;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *trailingSpaceLabelToContainer;

@end

@implementation VUploadProgressView

+ (instancetype)uploadProgressViewFromNib
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    for (id object in objects)
    {
        if ([object isKindOfClass:self])
        {
            return object;
        }
    }
    return nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    self.progressView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    self.finishedIconCheckmark.tintColor = [UIColor colorWithRed:0.91f green:0.91f blue:0.91f alpha:1.0f];
    self.finishedIconCheckmark.image = [self.finishedIconCheckmark.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.finishedIcon.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    [self setProgress:0 animated:NO];
    [self updateViewAccordingToCurrentState];
}

#pragma mark - Properties

- (void)setUploadTask:(VUploadTaskInformation *)uploadTask
{
    if (uploadTask == _uploadTask)
    {
        return;
    }
    
    if (_uploadTask)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:VUploadManagerTaskProgressNotification object:_uploadTask];
    }
    _uploadTask = uploadTask;
    self.previewImageView.image = uploadTask.previewImage;
    [self setProgress:0 animated:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskProgress:) name:VUploadManagerTaskProgressNotification object:uploadTask];
}

- (void)setState:(VUploadProgressViewState)state
{
    _state = state;
    [self updateViewAccordingToCurrentState];
}

- (void)setProgress:(CGFloat)progressPercent animated:(BOOL)animated
{
    void (^animations)(void) = ^(void)
    {
        self.progressWidthConstraint.constant = CGRectGetWidth(self.progressBackgroundView.frame) * progressPercent;
        if (animated)
        {
            [self layoutIfNeeded];
        }
    };
    if (animated)
    {
        [UIView animateWithDuration:kAnimationDuration animations:animations];
    }
    else
    {
        animations();
    }
}

- (void)updateViewAccordingToCurrentState
{
    self.uploadingIcon.hidden = YES;
    self.finalizingIcon.hidden = YES;
    self.failedIcon.hidden = YES;
    self.finishedIcon.hidden = YES;
    self.alternateFailedIcon.hidden = YES;
    self.trailingSpaceLabelToContainer.constant = kAccessoryButtonWidth;
    
    switch (self.state)
    {
        case VUploadProgressViewStateInProgress:
            self.titleLabel.text = NSLocalizedString(@"Uploading", @"");
            self.uploadingIcon.hidden = NO;
            break;
            
        case VUploadProgressViewStateCancelling:
            self.titleLabel.text = NSLocalizedString(@"Cancelling...", @"");
            self.uploadingIcon.hidden = NO;
            break;
            
        case VUploadProgressViewStateFinalizing:
            self.titleLabel.text = NSLocalizedString(@"UploadFinalizing", @"");
            self.finalizingIcon.hidden = NO;
            break;
            
        case VUploadProgressViewStateFailed:
            self.titleLabel.text = NSLocalizedString(@"UploadFailed", @"");
            self.failedIcon.hidden = NO;
            self.alternateFailedIcon.hidden = NO;
            self.trailingSpaceLabelToContainer.constant = 2 * kAccessoryButtonWidth;
            break;
            
        case VUploadProgressViewStateFinished:
            self.titleLabel.text = NSLocalizedString(@"UploadSuccess", @"");
            self.finishedIcon.hidden = NO;
            break;
            
        default:
            self.titleLabel.text = @"";
            break;
    }
    
    [self layoutIfNeeded];
}

#pragma mark - IBActions

- (IBAction)alternateAccessoryButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(alternateAccessoryButtonTappedInUploadProgressView:)])
    {
        [self.delegate alternateAccessoryButtonTappedInUploadProgressView:self];
    }
}

- (IBAction)accessoryButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(accessoryButtonTappedInUploadProgressView:)])
    {
        [self.delegate accessoryButtonTappedInUploadProgressView:self];
    }
}

#pragma mark - NSNotification handlers

- (void)taskProgress:(NSNotification *)notification
{
    int64_t bytesSent = [notification.userInfo[VUploadManagerBytesSentUserInfoKey] longLongValue];
    int64_t totalBytes = [notification.userInfo[VUploadManagerTotalBytesUserInfoKey] longLongValue];
    CGFloat progressPercent = (CGFloat)bytesSent / (CGFloat)totalBytes;
    [self setProgress:progressPercent animated:YES];
}

@end
