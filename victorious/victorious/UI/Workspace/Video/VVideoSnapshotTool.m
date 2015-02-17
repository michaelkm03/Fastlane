//
//  VMemeVideoTool.m
//  victorious
//
//  Created by Michael Sena on 2/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoSnapshotTool.h"
#import "VDependencyManager.h"

// ViewControllers
#import "VCVideoPlayerViewController.h"
#import "VSnapshotViewController.h"

@interface VVideoSnapshotTool () <VCVideoPlayerDelegate>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) NSURL *renderedMediaURL;

@property (nonatomic, strong) VCVideoPlayerViewController *videoPlayerViewController;
@property (nonatomic, strong) VSnapshotViewController *snapshotToolViewController;
@end

@implementation VVideoSnapshotTool

@synthesize selected = _selected;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _title = [dependencyManager stringForKey:@"title"];
        
        _videoPlayerViewController = [[VCVideoPlayerViewController alloc] initWithNibName:nil bundle:nil];
        _videoPlayerViewController.shouldFireAnalytics = NO;
        _videoPlayerViewController.loopWithoutComposition = YES;
        _videoPlayerViewController.shouldShowToolbar = YES;
        _videoPlayerViewController.shouldChangeVideoGravityOnDoubleTap = YES;
        _videoPlayerViewController.videoPlayerLayerVideoGravity = AVLayerVideoGravityResizeAspectFill;
        
        _snapshotToolViewController = [[VSnapshotViewController alloc] initWithNibName:nil bundle:nil];
    }
    return self;
}

#pragma mark - VVideoWorkspaceTool

- (void)setMediaURL:(NSURL *)mediaURL
{
    [self.videoPlayerViewController setItemURL:mediaURL loop:YES];
}

- (void)exportToURL:(NSURL *)url withCompletion:(void (^)(BOOL, UIImage *, NSError *))completion
{
}

- (NSURL *)mediaURL
{
    return self.renderedMediaURL;
}

#pragma mark - VWorkspaceTool

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (_selected)
    {
        [self.videoPlayerViewController.player play];
    }
    else
    {
        [self.videoPlayerViewController.player pause];
    }
}

- (UIViewController *)canvasToolViewController
{
    return self.videoPlayerViewController;
}

- (UIViewController *)inspectorToolViewController
{
    return self.snapshotToolViewController;
}

#pragma mark - VCVideoPlayerDelegate

- (void)videoPlayerReadyToPlay:(VCVideoPlayerViewController *)videoPlayer
{
    [videoPlayer.player play];
}

@end
