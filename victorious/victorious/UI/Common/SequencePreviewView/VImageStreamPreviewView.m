//
//  VImageStreamPreviewView.m
//  victorious
//
//  Created by Sharif Ahmed on 5/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageStreamPreviewView.h"

// Models + Helpers
#import "VStream.h"
#import "VStreamItem+Fetcher.h"

// Views + Helpers
#import "UIImageView+VLoadingAnimations.h"
#import "UIView+AutoLayout.h"

@interface VImageStreamPreviewView ()

@property (nonatomic, strong) UIImageView *previewImageView;

@end

@implementation VImageStreamPreviewView

#pragma mark - Lazy Property Accessors

- (UIImageView *)previewImageView
{
    if (_previewImageView == nil)
    {
        _previewImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _previewImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_previewImageView];
        [self v_addFitToParentConstraintsToSubview:_previewImageView];
    }
    return _previewImageView;
}

#pragma mark - VStreamPreviewView Overrides

- (void)setStream:(VStream *)stream
{
    [super setStream:stream];
    
    NSArray *imagePaths = [stream previewImagePaths];
    __weak VImageStreamPreviewView *weakSelf = self;
    [self.previewImageView fadeInImageAtURL:[imagePaths firstObject]
                           placeholderImage:nil
                                 completion:^(UIImage *image)
     {
         weakSelf.readyForDisplay = YES;
     }];
}

@end
