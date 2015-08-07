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
        
    }
    return self;
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    VAsset *HLSAsset = [sequence.firstNode httpLiveStreamingAsset];
    VAsset *mp4Asset = [sequence.firstNode mp4Asset];
    
    // First check mp4 asset to see if we should autoplay and only if it's under 30 seconds
    if ( mp4Asset.streamAutoplay.boolValue && mp4Asset.duration != nil && mp4Asset.duration.integerValue < 30 )
    {
        self.videoView.hidden = NO;
        self.playIconContainerView.hidden = YES;
        self.shouldLoop = YES;
        
        __weak VVideoSequencePreviewView *weakSelf = self;
        [self.videoView setItemURL:[NSURL URLWithString:mp4Asset.data]
                              loop:YES
                        audioMuted:YES
                alongsideAnimation:^
         {
             weakSelf.soundIndicator.hidden = NO;
             [weakSelf.soundIndicator startAnimating];
             [weakSelf makeBackgroundContainerViewVisible:YES];
         }];
    }
    // Else check HLS asset to see if we should autoplay and only if it's over 30 seconds
    else if ( HLSAsset.streamAutoplay.boolValue && HLSAsset.duration != nil && HLSAsset.duration.integerValue >= 30)
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
             weakSelf.soundIndicator.hidden = NO;
             [weakSelf.soundIndicator startAnimating];
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

@end
