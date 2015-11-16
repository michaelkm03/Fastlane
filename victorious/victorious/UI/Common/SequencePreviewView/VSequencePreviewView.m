//
//  VSequencePreviewView.m
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSequencePreviewView.h"
#import "VSequence+Fetcher.h"
#import "VStreamItem.h"
#import "VDependencyManager.h"
#import "VTextSequencePreviewView.h"
#import "VPollSequencePreviewView.h"
#import "VImageSequencePreviewView.h"
#import "VHTMLSequncePreviewView.h"
#import "VFailureSequencePreviewView.h"
#import "VVideoSequencePreviewView.h"
#import "VSequenceExpressionsObserver.h"
#import "victorious-Swift.h"

@interface VSequencePreviewView()

@property (nonatomic, strong) UITapGestureRecognizer *singleTapGesture;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGesture;
@property (nonatomic, strong, readwrite) VContentLikeButton *likeButton;
@property (nonatomic, strong) VSequenceExpressionsObserver *expressionsObserver;

@end

@implementation VSequencePreviewView

+ (Class)classTypeForSequence:(VSequence *)sequence
{
    Class classType = nil;
    if ([sequence isText])
    {
        classType = [VTextSequencePreviewView class];
    }
    else if ([sequence isPoll])
    {
        classType = [VPollSequencePreviewView class];
    }
    else if ([sequence isVideo])
    {
        if ( [sequence isRemoteVideoWithSource:[YouTubeVideoSequencePreviewView remoteSourceName]] )
        {
            classType = [YouTubeVideoSequencePreviewView class];
        }
        else if ( [sequence isGIFVideo] )
        {
            classType = [VBaseVideoSequencePreviewView class];
        }
        else
        {
            classType = [VVideoSequencePreviewView class];
        }
    }
    else if ([sequence isImage] || [sequence isPreviewImageContent])
    {
        classType = [VImageSequencePreviewView class];
    }
    else if ([sequence isWebContent])
    {
        classType = [VHTMLSequncePreviewView class];
    }
    else
    {
        classType = [VFailureSequencePreviewView class];
    }
    
    return classType;
}

+ (VSequencePreviewView *)sequencePreviewViewWithSequence:(VSequence *)sequence
{
    return [[[self classTypeForSequence:sequence] alloc] initWithFrame:CGRectZero];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self bringSubviewToFront:self.likeButton];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onContentTap)];
        _singleTapGesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:_singleTapGesture];
        
        _doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onContentDoubleTap)];
        _doubleTapGesture.numberOfTapsRequired = 2;
        [self addGestureRecognizer:_doubleTapGesture];
        
        [_singleTapGesture requireGestureRecognizerToFail:_doubleTapGesture];
        
        self.backgroundColor = [UIColor clearColor];
        
        _likeButton = [[VContentLikeButton alloc] init];
        [self addSubview:_likeButton];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_likeButton
                                                         attribute:NSLayoutAttributeTrailing
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTrailing
                                                        multiplier:1.0
                                                          constant:-12.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_likeButton
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottomMargin
                                                        multiplier:1.0
                                                          constant:-3.0f]];
        [_likeButton addTarget:self action:@selector(selectedLikeButton:) forControlEvents:UIControlEventTouchUpInside];
        _likeButton.hidden = YES;
        
        [self setGesturesEnabled:NO];
    }
    return self;
}

- (void)setStreamItem:(VStreamItem *)streamItem
{
    if ( [streamItem isKindOfClass:[VSequence class]] )
    {
        [self setSequence:(VSequence *)streamItem];
    }
    else
    {
#ifndef NS_BLOCK_ASSERTIONS
        NSString *errorString = [NSString stringWithFormat:@"VSequencePreviewView cannot handle streamItem of class %@!", NSStringFromClass([streamItem class])];
        NSAssert(false, errorString);
#endif
    }
}

- (void)setSequence:(VSequence *)sequence
{
    if ( sequence != self.sequence )
    {
        self.hasDeterminedPreferredBackgroundColor = NO;
    }
    
    [super setStreamItem:sequence];
    [self layoutIfNeeded];
}

- (VSequence *)sequence
{
    return [self.streamItem isKindOfClass:[VSequence class]] ? (VSequence *)self.streamItem : nil;
}

- (BOOL)canHandleSequence:(VSequence *)sequence
{
    if ([self class] == [[self class] classTypeForSequence:sequence])
    {
        return YES;
    }
    return NO;
}

+ (NSString *)reuseIdentifierForSequence:(VSequence *)sequence
                          baseIdentifier:(NSString *)baseIdentifier
                       dependencyManager:(VDependencyManager *)dependencyManager
{
    return [self reuseIdentifierForStreamItem:sequence baseIdentifier:baseIdentifier dependencyManager:dependencyManager];
}

- (UIColor *)defaultBackgroundColor
{
    return [UIColor blackColor];
}

- (void)updateBackgroundColorAnimated:(BOOL)animated
{
    void (^animations)() = ^
    {
        self.backgroundColor = self.updatedBackgroundColor;
    };
    if ( animated )
    {
        [UIView animateWithDuration:0.25f animations:animations];
    }
    else
    {
        animations();
    }
}

- (UIColor *)updatedBackgroundColor
{
    UIColor *nonDetailBackgroundColor = self.usePreferredBackgroundColor ? self.streamBackgroundColor : self.defaultBackgroundColor;
    return self.focusType == VFocusTypeDetail ? self.defaultBackgroundColor : nonDetailBackgroundColor;
}

#pragma mark - Gestures

- (void)setGesturesEnabled:(BOOL)enabled
{
    self.singleTapGesture.enabled = enabled;
    self.doubleTapGesture.enabled = enabled;
}

- (void)onContentTap
{
     // Subclasses may override
}

- (void)onContentDoubleTap
{
     // Subclasses may override
}

#pragma mark - VFocusable

@synthesize focusType = _focusType;

- (void)setFocusType:(VFocusType)focusType
{
    if ( focusType == _focusType )
    {
        return;
    }
    
    _focusType = focusType;
    
    switch (self.focusType)
    {
        case VFocusTypeNone:
            [self.likeButton hide];
            break;
        case VFocusTypeStream:
            [self.likeButton hide];
            break;
        case VFocusTypeDetail:
            [self.likeButton show];
            break;
    }
}

- (CGRect)contentArea
{
    return self.bounds;
}

#pragma mark - Like button

- (void)showLikeButton:(BOOL)shouldShowLikeButton
{
    const BOOL isLikeButtonTemplateEnabled = [self.dependencyManager numberForKey:VDependencyManagerLikeButtonEnabledKey].boolValue;
    BOOL willShowLikeButton = isLikeButtonTemplateEnabled && shouldShowLikeButton;
    
    if (willShowLikeButton)
    {
        __weak typeof(self) welf = self;
        self.expressionsObserver = [[VSequenceExpressionsObserver alloc] init];
        [self.expressionsObserver startObservingWithSequence:self.sequence onUpdate:^
         {
             __strong typeof(welf) strongSelf = welf;
             [strongSelf.likeButton setActive:strongSelf.sequence.isLikedByMainUser.boolValue];
             [strongSelf.likeButton setCount:strongSelf.sequence.likeCount.integerValue];
         }];
        self.likeButton.hidden = NO;
    }
    else
    {
        self.expressionsObserver = nil;
        self.likeButton.hidden = YES;
    }
}

- (void)selectedLikeButton:(UIButton *)likeButton
{
    [self.detailDelegate previewView:self didLikeSequence:self.sequence completion: nil];
}

@end
