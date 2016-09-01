//
//  VUploadProgressViewController.m
//  victorious
//
//  Created by Josh Hinman on 10/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUploadManager.h"
#import "VUploadProgressView.h"
#import "VUploadProgressViewController.h"
#import "VUploadTaskInformation.h"
#import "objc/runtime.h"

const CGFloat VUploadProgressViewControllerIdealHeight = 44.0f;
static const NSTimeInterval kFinishedTaskDisplayTime = 5.0; ///< Amount of time to keep finished tasks in view
static const NSTimeInterval kAnimationDuration = 0.2;

@interface VUploadProgressViewController () <VUploadProgressViewDelegate>

@property (nonatomic, readwrite) VUploadManager *uploadManager;
@property (nonatomic, readwrite) NSInteger numberOfUploads;
@property (nonatomic, strong) NSMutableArray /* VUploadProgressView */ *uploadProgressViews;

@end

@implementation VUploadProgressViewController

static NSMutableDictionary *associatedUploadManagers;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _uploadProgressViews = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (instancetype)viewControllerForUploadManager:(VUploadManager *)uploadManager
{
    VUploadProgressViewController *existingViewController = uploadManager.associatedProgressViewController;
    if (existingViewController != nil)
    {
        return existingViewController;
    }
    
    VUploadProgressViewController *viewController = [[self alloc] initWithNibName:nil bundle:nil];
    viewController.uploadManager = uploadManager;
    return viewController;
}

- (void)setUploadManager:(VUploadManager *)uploadManager
{
    _uploadManager = uploadManager;
    uploadManager.associatedProgressViewController = self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Lifecycle

- (void)loadView
{
    self.view = [[UIView alloc] init];
    self.view.clipsToBounds = YES;
    [self.uploadManager getQueuedUploadTasksWithCompletion:^(NSArray *tasks)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            for (VUploadTaskInformation *task in tasks)
            {
                VUploadProgressViewState state = [self.uploadManager isTaskInProgress:task] ? VUploadProgressViewStateInProgress : VUploadProgressViewStateFailed;
                [self addUpload:task withState:state animated:YES];
            }
            self.numberOfUploads = (NSInteger)tasks.count;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(uploadTaskBegan:)
                                                         name:VUploadManagerTaskBeganNotification
                                                       object:self.uploadManager];
        });
    }];
}

#pragma mark - Properties

- (void)setNumberOfUploads:(NSInteger)numberOfUploads
{
    if (numberOfUploads == _numberOfUploads)
    {
        return;
    }
    _numberOfUploads = numberOfUploads;
    
    if ([self.delegate respondsToSelector:@selector(uploadProgressViewController:isNowDisplayingThisManyUploads:)])
    {
        [self.delegate uploadProgressViewController:self isNowDisplayingThisManyUploads:numberOfUploads];
    }
}

#pragma mark - Add/Remove Subviews

- (void)addUpload:(VUploadTaskInformation *)uploadTask withState:(VUploadProgressViewState)state animated:(BOOL)animated
{
    if (uploadTask.isGIF) {
        return;
    }

    NSArray *existingProgressViews = [self.uploadProgressViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K==%@", NSStringFromSelector(@selector(uploadTask)), uploadTask]];
    if ( existingProgressViews.count != 0 )
    {
        VUploadProgressView *upv = existingProgressViews[0];
        [self.view bringSubviewToFront:upv];
        upv.state = state;
        return;
    }
    
    VUploadProgressView *progressView = [VUploadProgressView uploadProgressViewFromNib];
    progressView.translatesAutoresizingMaskIntoConstraints = NO;
    progressView.uploadTask = uploadTask;
    progressView.delegate = self;
    progressView.state = state;
    [self.view addSubview:progressView];
    
    [self.uploadProgressViews addObject:progressView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[progressView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(progressView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[progressView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(progressView)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadTaskFailed:) name:VUploadManagerTaskFailedNotification object:uploadTask];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadTaskFinished:) name:VUploadManagerTaskFinishedNotification object:uploadTask];
    
    self.numberOfUploads = (NSInteger)self.uploadProgressViews.count;
    
    if (animated)
    {
        CGRect newFrame = progressView.frame;
        newFrame.origin.y = -CGRectGetHeight(newFrame);
        progressView.frame = newFrame;
        [UIView animateWithDuration:kAnimationDuration
                         animations:^(void)
        {
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)removeUpload:(VUploadProgressView *)uploadProgressView animated:(BOOL)animated
{
    void (^animations)() = ^(void)
    {
        CGRect currentFrame = uploadProgressView.frame;
        uploadProgressView.frame = CGRectMake(CGRectGetMinX(currentFrame), -CGRectGetHeight(currentFrame), CGRectGetWidth(currentFrame), CGRectGetHeight(currentFrame));
    };
    
    void (^completion)(BOOL) = ^(BOOL finished)
    {
        [uploadProgressView removeFromSuperview];
        [self.uploadProgressViews removeObject:uploadProgressView];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:VUploadManagerTaskFailedNotification object:uploadProgressView.uploadTask];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:VUploadManagerTaskFinishedNotification object:uploadProgressView.uploadTask];
        
        self.numberOfUploads = (NSInteger)self.uploadProgressViews.count;
    };
    
    if (animated)
    {
        [UIView animateWithDuration:kAnimationDuration animations:animations completion:completion];
    }
    else
    {
        completion(YES);
    }
}

#pragma mark - VUploadProgressViewDelegate methods

- (void)accessoryButtonTappedInUploadProgressView:(VUploadProgressView *)uploadProgressView
{
    BOOL isFailed = uploadProgressView.state == VUploadProgressViewStateFailed;
    
    switch (uploadProgressView.state)
    {
        case VUploadProgressViewStateFailed:
        case VUploadProgressViewStateInProgress:
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"UploadCancelAreYouSure", @"")
                                                                                     message:nil
                                                                              preferredStyle:UIAlertControllerStyleActionSheet];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"NoKeepUploading", @"")
                                                                style:UIAlertActionStyleDefault
                                                              handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"YesCancelUpload", @"")
                                                                style:UIAlertActionStyleDestructive
                                                              handler:^(UIAlertAction *action)
                                        {
                                            if (uploadProgressView.state == VUploadProgressViewStateInProgress)
                                            {
                                                uploadProgressView.state = VUploadProgressViewStateCanceling;
                                            }
                                            else
                                            {
                                                [self removeUpload:uploadProgressView animated:YES];
                                            }
                                            
                                            NSString *eventName = isFailed ? VTrackingEventUserDidCancelFailedUpload : VTrackingEventUserDidCancelPendingUpload;
                                            [[VTrackingManager sharedInstance] trackEvent:eventName];
                                            
                                            [self.uploadManager cancelUploadTask:uploadProgressView.uploadTask];
                                        }]];
            [self.parentViewController presentViewController:alertController animated:YES completion:nil];
        }
            break;
        case VUploadProgressViewStateFinalizing:
        case VUploadProgressViewStateFinished:
            [self removeUpload:uploadProgressView animated:YES];
            break;
            
        default:
            break;
    }
}

- (void)alternateAccessoryButtonTappedInUploadProgressView:(VUploadProgressView *)uploadProgressView
{
    switch (uploadProgressView.state)
    {
        case VUploadProgressViewStateFailed:
            [self.uploadManager enqueueUploadTask:uploadProgressView.uploadTask onComplete:nil];
            uploadProgressView.state = VUploadProgressViewStateInProgress;
            [uploadProgressView setProgress:0 animated:NO];
            break;
        default:
            break;
    }
}

#pragma mark - NSNotification handlers

- (void)uploadTaskBegan:(NSNotification *)notification
{
    [self addUpload:notification.userInfo[VUploadManagerUploadTaskUserInfoKey] withState:VUploadProgressViewStateInProgress animated:YES];
}

- (void)uploadTaskFailed:(NSNotification *)notification
{
    for (VUploadProgressView *uploadProgressView in self.uploadProgressViews)
    {
        if ([uploadProgressView.uploadTask isEqual:notification.object])
        {
            NSError *error = notification.userInfo[VUploadManagerErrorUserInfoKey];
            if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled)
            {
                [self removeUpload:uploadProgressView animated:YES];
            }
            else
            {
                uploadProgressView.state = VUploadProgressViewStateFailed;
                [uploadProgressView setProgress:0 animated:YES];
            }
            break;
        }
    }
}

- (void)uploadTaskFinished:(NSNotification *)notification
{
    for (VUploadProgressView *uploadProgressView in self.uploadProgressViews)
    {
        if ([uploadProgressView.uploadTask isEqual:notification.object])
        {
            uploadProgressView.state = VUploadProgressViewStateFinished;
            if (self.numberOfUploads == 1)
            {
                typeof(self) __weak weakSelf = self;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kFinishedTaskDisplayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void)
                               {
                                   __strong typeof(weakSelf) strongSelf = weakSelf;
                                   if (strongSelf && [strongSelf.uploadProgressViews containsObject:uploadProgressView])
                                   {
                                       [self removeUpload:uploadProgressView animated:YES];
                                   }
                               });
            }
            break;
        }
    }
}

@end
