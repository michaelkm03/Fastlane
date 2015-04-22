//
//  VAbstractStreamCollectionCell.m
//  victorious
//
//  Created by Michael Sena on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractStreamCollectionCell.h"

// Views
#import "UIImageView+VLoadingAnimations.h"
#import "UIView+AutoLayout.h"
#import "VTextPostViewController.h"
#import "VPollView.h"
#import "UIColor+VHex.h"

// Models
#import "VUser+Fetcher.h"
#import "VSequence+Fetcher.h"
#import "VAsset+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAnswer+Fetcher.h"

@interface VAbstractStreamCollectionCell ()

@property (nonatomic, strong, readwrite) UIView *previewView;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) VTextPostViewController *textPostViewController;
@property (nonatomic, strong) VPollView *pollView;

@property (nonatomic, strong, readwrite) VDependencyManager *dependencyManager;

@end

@implementation VAbstractStreamCollectionCell

#pragma mark - Class Methods

+ (NSString *)reuseIdentifierForSequence:(VSequence *)sequence
{
    NSAssert(false, @"Must implement in subclasses!");
    return nil;
}

#pragma mark - Property Accessors

- (UIView *)previewView
{
    if (_previewView == nil)
    {
        _previewView = [[UIView alloc] initWithFrame:CGRectZero];
        _previewView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _previewView;
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    if ([sequence isText])
    {
        VLog(@"%@, text cell", self);
        
        if (self.textPostViewController == nil)
        {
            self.textPostViewController = [VTextPostViewController newWithDependencyManager:self.dependencyManager];
            [self.previewView addSubview:self.textPostViewController.view];
            [self.previewView v_addFitToParentConstraintsToSubview:self.textPostViewController.view];
        }
        
        VAsset *textAsset = [self.sequence.firstNode textAsset];
        if ( textAsset.data != nil )
        {
            VAsset *imageAsset = [self.sequence.firstNode imageAsset];
            self.textPostViewController.text = textAsset.data;
            self.textPostViewController.color = [UIColor v_colorFromHexString:textAsset.backgroundColor];
            self.textPostViewController.imageURL = [NSURL URLWithString:imageAsset.data];
        }
    }
    else if ([sequence isPoll])
    {
        VLog(@"%@, poll cell", self);
        if (self.pollView == nil)
        {
            self.pollView = [[VPollView alloc] initWithFrame:CGRectZero];
            [self.previewView addSubview:self.pollView];
            [self.previewView v_addFitToParentConstraintsToSubview:self.pollView];
        }
        [self.pollView setImageURL:[[[sequence firstNode] answerA] previewMediaURL]
                     forPollAnswer:VPollAnswerA];
        [self.pollView setImageURL:[[[sequence firstNode] answerB] previewMediaURL]
                     forPollAnswer:VPollAnswerB];
    }
    else if ([sequence isVideo])
    {
        VLog(@"%@, video cell", self);
    }
    else if ([sequence isImage])
    {
        VLog(@"%@, image cell", self);
        if (self.previewImageView == nil)
        {
            UIImageView *previewImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            previewImageView.translatesAutoresizingMaskIntoConstraints = NO;
            [self.previewView addSubview:previewImageView];
            [self.previewView v_addFitToParentConstraintsToSubview:previewImageView];
            self.previewImageView = previewImageView;
        }
        [self.previewImageView fadeInImageAtURL:sequence.inStreamPreviewImageURL];
    }
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
}

#pragma mark - VBackgroundContainer

- (UIView *)loadingBackgroundContainerView
{
    return self.previewView;
}

@end
