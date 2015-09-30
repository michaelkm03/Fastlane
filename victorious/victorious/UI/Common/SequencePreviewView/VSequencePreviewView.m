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
        if ( [sequence isRemoteVideo] )
        {
            classType = [VRemoteVideoSequencePreviewView class];
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

- (BOOL)likeButtonDisabled
{
    return NO;
}

- (void)setSequence:(VSequence *)sequence
{
    if ( sequence != self.sequence )
    {
        self.hasDeterminedPreferredBackgroundColor = NO;
    }
    
    [super setStreamItem:sequence];
    
    if ( !self.likeButtonDisabled )
    {
        [self configureLikeButtonForSequence:sequence];
    }
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
        UIColor *nonDetailBackgroundColor = self.usePreferredBackgroundColor ? self.streamBackgroundColor : self.defaultBackgroundColor;
        self.backgroundColor = self.focusType == VFocusTypeDetail ? self.defaultBackgroundColor : nonDetailBackgroundColor;
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
}

- (CGRect)contentArea
{
    return self.bounds;
}

#pragma mark - Like button

- (void)configureLikeButtonForSequence:(VSequence *)sequence
{
    if ( [self.dependencyManager numberForKey:VDependencyManagerLikeButtonEnabledKey].boolValue )
    {
        if ( self.likeButton == nil )
        {
            VContentLikeButton *likeButton = [[VContentLikeButton alloc] init];
            [self addSubview:likeButton];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:likeButton
                                                             attribute:NSLayoutAttributeTrailing
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1.0
                                                              constant:-12.0f]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:likeButton
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeBottomMargin
                                                            multiplier:1.0
                                                              constant:-3.0f]];
            
            [self layoutIfNeeded];
            self.likeButton = likeButton;
            
            [self.likeButton addTarget:self action:@selector(selectedLikeButton:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        self.likeButton.hidden = NO;
        
        self.expressionsObserver = nil;
        self.expressionsObserver = [[VSequenceExpressionsObserver alloc] init];
        
        __weak typeof(self) welf = self;
        [self.expressionsObserver startObservingWithSequence:self.sequence onUpdate:^
         {
             __strong typeof(self) strongSelf = welf;
             [strongSelf.likeButton setActive:sequence.isLikedByMainUser.boolValue];
             [strongSelf.likeButton setCount:sequence.likeCount.integerValue];
         }];
    }
}

- (void)selectedLikeButton:(UIButton *)likeButton
{
    likeButton.enabled = NO;
    [self.detailDelegate previewView:self didLikeSequence:self.sequence completion:^(BOOL success)
     {
         likeButton.enabled = YES;
     }];
}

@end
