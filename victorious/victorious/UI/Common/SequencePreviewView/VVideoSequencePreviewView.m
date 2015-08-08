//
//  VVideoSequencePreviewView.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoSequencePreviewView.h"
#import "victorious-Swift.h"

@interface VVideoSequencePreviewView ()

@property (nonatomic, strong) SoundBarView *soundIndicator;
@property (nonatomic, strong) UIButton *replayButton;
@property (nonatomic, assign) BOOL shouldLoop;

@end

@implementation VVideoSequencePreviewView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _soundIndicator = [[SoundBarView alloc] init];
        _soundIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        _soundIndicator.hidden = YES;
        [self addSubview:_soundIndicator];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_soundIndicator(25)]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:NSDictionaryOfVariableBindings(_soundIndicator)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_soundIndicator(25)]-10-|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:NSDictionaryOfVariableBindings(_soundIndicator)]];
        
        _replayButton = [[UIButton alloc] init];
        _replayButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_replayButton addTarget:self action:@selector(replayPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_replayButton setImage:[UIImage imageNamed:@"restart_video"] forState:UIControlStateNormal];
        _replayButton.hidden = YES;
        [self addSubview:_replayButton];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_replayButton(50)]-10-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_replayButton)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-25-[_replayButton(50)]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_replayButton)]];
        
        
    }
    return self;
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    self.soundIndicator.hidden = YES;
    self.replayButton.hidden = YES;
    
    VAsset *HLSAsset = [sequence.firstNode httpLiveStreamingAsset];
    VAsset *mp4Asset = [sequence.firstNode mp4Asset];
    
    // First check mp4 asset to see if we should autoplay and only if it's under 30 seconds
//    if ( !mp4Asset.streamAutoplay.boolValue && mp4Asset.duration != nil && mp4Asset.duration.integerValue < 30 )
#warning - Testing
    if ( !mp4Asset.streamAutoplay.boolValue )
    {
        self.videoView.hidden = NO;
        self.playIconContainerView.hidden = YES;
        self.shouldLoop = YES;
        
        __weak VVideoSequencePreviewView *weakSelf = self;
        [self.videoView setItemURL:[NSURL URLWithString:mp4Asset.data]
                              loop:NO
                        audioMuted:YES
                alongsideAnimation:^
         {
             [weakSelf makeBackgroundContainerViewVisible:YES];
         }];
    }
    // Else check HLS asset to see if we should autoplay and only if it's over 30 seconds
    else if ( !HLSAsset.streamAutoplay.boolValue && HLSAsset.duration != nil && HLSAsset.duration.integerValue >= 30)
    {
        
        self.videoView.hidden = NO;
        self.playIconContainerView.hidden = YES;
        self.shouldLoop = NO;
        
        __weak VVideoSequencePreviewView *weakSelf = self;
        [self.videoView setItemURL:[NSURL URLWithString:HLSAsset.data]
                              loop:NO
                        audioMuted:YES
                alongsideAnimation:^
         {
             [weakSelf makeBackgroundContainerViewVisible:YES];
         }];
        
    }
    else
    {
        self.videoView.hidden = YES;
        self.playIconContainerView.hidden = NO;
        self.soundIndicator.hidden = YES;
    }
}

- (void)setHasFocus:(BOOL)hasFocus
{
    [super setHasFocus:hasFocus];
    
    if (hasFocus && self.videoView.hidden == NO)
    {
        self.soundIndicator.hidden = NO;
    }
    else
    {
        self.soundIndicator.hidden = YES;
    }
}

#pragma mark - Actions

- (void)replayPressed:(id)sender
{
    self.replayButton.hidden = YES;
    self.soundIndicator.hidden = NO;
    [self.videoView play];
}

#pragma mark - Video Player Delegate

- (void)videoDidReachEnd:(VVideoView *__nonnull)videoView
{
    self.soundIndicator.hidden = YES;
    self.replayButton.hidden = NO;
}

@end
