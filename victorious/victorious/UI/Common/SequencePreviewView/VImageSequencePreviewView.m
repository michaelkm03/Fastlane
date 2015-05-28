//
//  VImageSequencePreviewView.m
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageSequencePreviewView.h"

// Models + Helpers
#import "VSequence+Fetcher.h"

// Views + Helpers
#import "UIImageView+VLoadingAnimations.h"
#import "UIView+AutoLayout.h"

@interface VImageSequencePreviewView ()

@property (nonatomic, strong) UIImageView *previewImageView;

@end

@implementation VImageSequencePreviewView

#pragma mark - Lazy Property Accessors

- (UIImageView *)previewImageView
{
    if (_previewImageView == nil)
    {
        _previewImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _previewImageView.contentMode = UIViewContentModeScaleAspectFill;
        _previewImageView.clipsToBounds = YES;
        [self addSubview:_previewImageView];
        [self v_addFitToParentConstraintsToSubview:_previewImageView];
    }
    return _previewImageView;
}

#pragma mark - VSequencePreviewView Overrides

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    [self.previewImageView fadeInImageAtURL:sequence.inStreamPreviewImageURL
                           placeholderImage:nil
                                 completion:^(UIImage *image)
     {
         self.readyForDisplay = YES;
     }];
}

@end
